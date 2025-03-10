# frozen_string_literal: true

class ZohoSign::BaseService < ActiveCall::Base
  CACHE_KEY = { access_token: 'zoho_sign/base_service/access_token' }.freeze

  config_accessor :base_url, default: 'https://sign.zoho.com/api/v1', instance_writer: false
  config_accessor :cache, default: ActiveSupport::Cache::MemoryStore.new, instance_writer: false
  config_accessor :logger, default: Logger.new($stdout), instance_writer: false
  config_accessor :log_level, default: :info, instance_writer: false
  config_accessor :log_headers, default: false, instance_writer: false
  config_accessor :log_bodies, default: false, instance_writer: false
  config_accessor :client_id, :client_secret, :refresh_token, instance_writer: false

  attr_reader :facade

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = base_url
      conn.request :authorization, 'Zoho-oauthtoken', -> { access_token }
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
    access_token = cache.read(CACHE_KEY[:access_token])
    return access_token if access_token.present?

    service = ZohoSign::AccessToken::GetService.call
    cache.fetch(CACHE_KEY[:access_token], expires_in: [service.expires_in - 10, 0].max) { service.facade.access_token }
  end

  def validate_response
    raise ZohoSign::ServerError, response if response.status >= 500

    raise ZohoSign::BadRequestError, response if bad_request?
    raise ZohoSign::UnauthorizedError, response if unauthorized?
    raise ZohoSign::TooManyRequestsError, response if too_many_requests?

    raise ZohoSign::ClientError, response if response.status >= 400
  end

  def bad_request?
    response.status == 400
  end

  def unauthorized?
    response.status == 401
  end

  def too_many_requests?
    return false unless response.status == 400 && response.body.key?('error_description')

    response.body['error_description'].include?('too many requests')
  end
end
