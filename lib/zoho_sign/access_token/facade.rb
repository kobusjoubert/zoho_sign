# frozen_string_literal: true

class ZohoSign::AccessToken::Facade
  attr_reader :access_token, :scope, :api_domain, :token_type, :expires_in, :expires_at

  def initialize(hash)
    @access_token = hash['access_token']
    @scope        = hash['scope']
    @api_domain   = hash['api_domain']
    @token_type   = hash['token_type']
    @expires_in   = hash['expires_in']
  end
end
