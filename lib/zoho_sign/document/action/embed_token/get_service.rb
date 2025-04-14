# frozen_string_literal: true

class ZohoSign::Document::Action::EmbedToken::GetService < ZohoSign::BaseService
  attr_reader :request_id, :action_id, :host

  validates :request_id, :action_id, :host, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(request_id:, action_id:, host:)
    @request_id = request_id
    @action_id  = action_id
    @host       = host
  end

  # Get a signing URL.
  #
  # https://www.zoho.com/sign/api/embedded-signing.html
  #
  # A unique signing URL will be generated, which will be valid for two minutes. If the signing page is not open by
  # then, a new link needs to be generated and it is a one-time usable URL.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::Action::EmbedToken::GetService.call(request_id: '', action_id: '', host: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoSign::Document::Action::EmbedToken::Facade ...>
  #   service.facade.sign_url
  #   service.sign_url
  #
  # POST /api/v1/requests/:request_id/actions/:action_id/embedtoken
  def call
    connection.post("/api/v1/requests/#{request_id}/actions/#{action_id}/embedtoken", **params)
  end

  private

  def params
    {
      host: host
    }
  end

  def set_facade
    @facade = ZohoSign::Document::Action::EmbedToken::Facade.new(response.body)
  end
end
