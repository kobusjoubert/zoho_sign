# frozen_string_literal: true

class ZohoSign::Document::GetService < ZohoSign::BaseService
  attr_reader :id

  after_call :validate_response, :set_facade

  delegate_missing_to :@facade

  validates :id, presence: true

  def initialize(id: nil)
    @id = id
  end

  # Get a document.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::GetService.call(id: '')
  #
  #   service.valid? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoSign::Document::Facade @request_status="" ...>
  #   service.facade.request_name
  #   service.request_name
  #
  def call
    connection.get("requests/#{id}")
  end

  private

  def validate_response
    raise ZohoSign::ServerError.new(response) if response.status >= 500
    raise ZohoSign::UnauthorizedError.new(response) if unauthorized?
    raise ZohoSign::TooManyRequestsError.new(response) if too_many_requests?
    raise ZohoSign::ClientError.new(response) if response.status >= 400
  end

  def set_facade
    @facade = ZohoSign::Document::Facade.new(response.body['requests'])
  end
end
