# frozen_string_literal: true

class ZohoSign::Document::Action::EmbedToken::GetService < ZohoSign::BaseService
  attr_reader :id, :request_id, :host

  after_call :set_facade

  delegate_missing_to :@facade

  validates :id, :request_id, :host, presence: true

  def initialize(id:, request_id:, host:)
    @id         = id
    @request_id = request_id
    @host       = host
  end

  # Get a document.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::Action::EmbedToken::GetService.call(id: '', request_id: '', host: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoSign::Document::Action::EmbedToken::Facade ...>
  #   service.facade.request_name
  #   service.request_name
  #
  # POST /api/v1/requests/:request_id/actions/:id/embedtoken
  def call
    connection.post("/api/v1/requests/#{request_id}/actions/#{id}/embedtoken", **params)
  end

  private

  def params
    {
      host: host
    }
  end

  def set_facade
    @facade = ZohoSign::Document::Action::EmbedToken.new(response.body)
  end
end
