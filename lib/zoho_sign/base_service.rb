# frozen_string_literal: true

class ZohoSign::BaseService < ActiveCall::Base
  self.abstract_class = true

  CACHE_KEY = { access_token: 'zoho_sign/base_service/access_token' }.freeze

  EXCEPTION_MAPPING = {
    bad_request:                   ZohoSign::BadRequestError,
    unauthorized:                  ZohoSign::UnauthorizedError,
    forbidden:                     ZohoSign::ForbiddenError,
    not_found:                     ZohoSign::NotFoundError,
    proxy_authentication_required: ZohoSign::ProxyAuthenticationRequiredError,
    request_timeout:               ZohoSign::RequestTimeoutError,
    conflict:                      ZohoSign::ConflictError,
    unprocessable_entity:          ZohoSign::UnprocessableEntityError,
    too_many_requests:             ZohoSign::TooManyRequestsError,
    client_error:                  ZohoSign::ClientError,
    server_error:                  ZohoSign::ServerError
  }.freeze

  config_accessor :base_url, default: 'https://sign.zoho.com/api/v1', instance_writer: false
  config_accessor :cache, default: ActiveSupport::Cache::MemoryStore.new, instance_writer: false
  config_accessor :logger, default: Logger.new($stdout), instance_writer: false
  config_accessor :log_level, default: :info, instance_writer: false
  config_accessor :log_headers, default: false, instance_writer: false
  config_accessor :log_bodies, default: false, instance_writer: false
  config_accessor :client_id, :client_secret, :refresh_token, instance_writer: false

  attr_reader :facade

  validate on: :response do
    throw :abort if response.is_a?(Enumerable)

    errors.add(:base, :server_error) and throw :abort if response.status >= 500

    errors.add(:base, :unauthorized) and throw :abort if unauthorized?
    errors.add(:base, :forbidden) and throw :abort if forbidden?
    errors.add(:base, :not_found) and throw :abort if not_found?
    errors.add(:base, :proxy_authentication_required) and throw :abort if proxy_authentication_required?
    errors.add(:base, :request_timeout) and throw :abort if request_timeout?
    errors.add(:base, :conflict) and throw :abort if conflict?
    errors.add(:base, :unprocessable_entity) and throw :abort if unprocessable_entity?
    errors.add(:base, :too_many_requests) and throw :abort if too_many_requests?

    # Check for bad_request here since too_many_requests also has a status of 400.
    errors.add(:base, :bad_request) and throw :abort if bad_request?

    # We'll use client_error for everything else that we don't have an explicit exception class for.
    errors.add(:base, :client_error) and throw :abort if response.status >= 400
  end

  class << self
    def call!(...)
      super
    rescue ActiveCall::ValidationError => e
      raise zoho_sign_validation_error(e)
    rescue ActiveCall::RequestError => e
      raise zoho_sign_request_error(e)
    end

    def zoho_sign_validation_error(exception)
      ZohoSign::ValidationError.new(exception.errors, exception.message)
    end

    def zoho_sign_request_error(exception)
      exception_for(exception.response, exception.errors, exception.message)
    end

    def exception_for(response, errors, message = nil)
      exception_type = errors.details[:base].first[:error]

      case exception_type
      when *EXCEPTION_MAPPING.keys
        EXCEPTION_MAPPING[exception_type].new(response, errors, message)
      else
        ZohoSign::RequestError.new(response, errors, message)
      end
    end
  end

  private

  delegate :exception_for, to: :class

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = base_url
      conn.request :authorization, 'Zoho-oauthtoken', -> { access_token }
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

  def access_token
    access_token = ENV['ZOHO_SIGN_ACCESS_TOKEN'].presence || cache.read(CACHE_KEY[:access_token])
    return access_token if access_token.present?

    service = ZohoSign::AccessToken::GetService.call
    cache.fetch(CACHE_KEY[:access_token], expires_in: [service.expires_in - 10, 0].max) { service.facade.access_token }
  end

  def bad_request?
    response.status == 400
  end

  def unauthorized?
    response.status == 401
  end

  def forbidden?
    response.status == 403
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
    return true if [4066, 20405].include?(response.body['code'])

    false
  end

  # TODO: Confirm.
  def proxy_authentication_required?
    response.status == 407
  end

  # TODO: Confirm.
  def request_timeout?
    response.status == 408
  end

  # TODO: Confirm.
  def conflict?
    response.status == 409
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
