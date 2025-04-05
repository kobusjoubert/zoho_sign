# frozen_string_literal: true

class ZohoSign::BaseService < ActiveCall::Base
  include ActiveCall::Api

  self.abstract_class = true

  CACHE_KEY = { access_token: 'zoho_sign/base_service/access_token' }.freeze

  config_accessor :base_url, default: 'https://sign.zoho.com/api/v1', instance_writer: false
  config_accessor :cache, default: ActiveSupport::Cache::MemoryStore.new, instance_writer: false
  config_accessor :logger, default: Logger.new($stdout), instance_writer: false
  config_accessor :log_level, default: :info, instance_writer: false
  config_accessor :log_headers, default: false, instance_writer: false
  config_accessor :log_bodies, default: false, instance_writer: false
  config_accessor :client_id, :client_secret, :refresh_token, instance_writer: false

  attr_reader :access_token, :facade

  before_call :set_access_token

  validate on: :request do
    next if is_a?(ZohoSign::AccessToken::GetService)

    errors.merge!(access_token_service.errors) if access_token.nil? && !access_token_service.success?
  end

  class << self
    def exception_mapping
      {
        validation_error:              ZohoSign::ValidationError,
        request_error:                 ZohoSign::RequestError,
        client_error:                  ZohoSign::ClientError,
        server_error:                  ZohoSign::ServerError,
        bad_request:                   ZohoSign::BadRequestError,
        unauthorized:                  ZohoSign::UnauthorizedError,
        forbidden:                     ZohoSign::ForbiddenError,
        not_found:                     ZohoSign::NotFoundError,
        not_acceptable:                ZohoSign::NotAcceptableError,
        proxy_authentication_required: ZohoSign::ProxyAuthenticationRequiredError,
        request_timeout:               ZohoSign::RequestTimeoutError,
        conflict:                      ZohoSign::ConflictError,
        gone:                          ZohoSign::GoneError,
        unprocessable_entity:          ZohoSign::UnprocessableEntityError,
        too_many_requests:             ZohoSign::TooManyRequestsError,
        internal_server_error:         ZohoSign::InternalServerError,
        not_implemented:               ZohoSign::NotImplementedError,
        bad_gateway:                   ZohoSign::BadGatewayError,
        service_unavailable:           ZohoSign::ServiceUnavailableError,
        gateway_timeout:               ZohoSign::GatewayTimeoutError
      }.freeze
    end
  end

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = base_url
      conn.request :authorization, 'Zoho-oauthtoken', access_token
      conn.request :multipart
      conn.request :url_encoded
      conn.request :retry
      conn.response :json
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(Authorization:).*"(.+)."/i, '\1 [FILTERED]')
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def logger_options
    {
      headers:   log_headers,
      log_level: log_level,
      bodies:    log_bodies,
      formatter: Faraday::Logging::ColorFormatter, prefix: { request: 'ZohoSign', response: 'ZohoSign' }
    }
  end

  def set_access_token
    @access_token = ENV['ZOHO_SIGN_ACCESS_TOKEN'].presence || cache.read(CACHE_KEY[:access_token])
    return if @access_token.present?
    return unless access_token_service.success?

    @access_token = cache.fetch(CACHE_KEY[:access_token], expires_in: [access_token_service.expires_in - 10, 0].max) do
      access_token_service.facade.access_token
    end
  end

  def access_token_service
    @_access_token_service ||= ZohoSign::AccessToken::GetService.call
  end

  def forbidden?
    return true if response.status == 403
    return false unless response.status == 400 && response.body.key?('code')

    # 4003: Access to view the document is denied.
    return true if [4003].include?(response.body['code'])

    false
  end

  def not_found?
    return true if response.status == 404
    return false unless response.status == 400 && response.body.key?('code')

    # 4066: Invalid Request ID.
    # 20405: Invalid Template ID.
    return true if [4_066, 20_405].include?(response.body['code'])

    false
  end

  def unprocessable_entity?
    return true if response.status == 422
    return false unless response.status == 400 && response.body.key?('code')

    # 4021: Something went wrong. One or more fields contain errors.
    # 9009: ...
    # 9043: Extra key found.
    # 9056: Action array size mismatch from the templates.
    return true if [4021, 9043, 9009, 9056].include?(response.body['code'])

    false
  end

  def too_many_requests?
    return false unless response.status == 400 && response.body.key?('error_description')

    response.body['error_description'].include?('too many requests')
  end
end
