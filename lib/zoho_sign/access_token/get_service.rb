# frozen_string_literal: true

class ZohoSign::AccessToken::GetService < ZohoSign::BaseService
  skip_callback :call, :before, :set_access_token

  after_call :set_facade

  delegate_missing_to :@facade

  # Get access token.
  #
  # https://www.zoho.com/accounts/protocol/oauth/web-apps/access-token-expiry.html
  #
  # ==== Examples
  #
  #   service = ZohoSign::AccessToken::GetService.call
  #   service.access_token # => '1000.xxxx.yyyy'
  #   service.expires_in # => 3600
  #
  # POST /oauth/v2/token
  def call
    connection.post('oauth/v2/token', params.to_param)
  end

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = 'https://accounts.zoho.com'
      conn.request :retry
      conn.response :json
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(refresh_token|client_id|client_secret)=([^&]+)/i, '\1=[FILTERED]')
        logger.filter(/"access_token":"([^"]+)"/i, '"access_token":"[FILTERED]"')
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def params
    {
      client_id:     client_id,
      client_secret: client_secret,
      refresh_token: refresh_token,
      grant_type:    'refresh_token'
    }
  end

  def unauthorized?
    response.status == 200 && response.body.key?('error')
  end

  def set_facade
    @facade = ZohoSign::AccessToken::Facade.new(response.body)
  end
end
