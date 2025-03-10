# frozen_string_literal: true

class ZohoSign::BaseService < ActiveCall::Base
  config_accessor :base_url, default: 'https://sign.zoho.com/api/v1', instance_writer: false
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
      conn.request :authorization, 'Zoho-oauthtoken', -> { get_access_token }
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

  def get_access_token
    service = ZohoSign::AccessToken::GetService.call
    self.access_token = service.facade.access_token
    access_token
    # TODO: Persist access_token to cache...
  end

  def too_many_requests?
    return false unless response.status == 400 && response.body.key?('error_description')

    response.body['error_description'].include?('too many requests')
  end

  def unauthorized?
    response.status == 401
  end
end
