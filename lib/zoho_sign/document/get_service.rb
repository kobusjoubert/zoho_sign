# frozen_string_literal: true

class ZohoSign::Document::GetService < ZohoSign::BaseService
  attr_reader :id

  after_call :set_facade

  delegate_missing_to :@facade

  validates :id, presence: true

  def initialize(id:)
    @id = id
  end

  # Get a document.
  #
  # https://www.zoho.com/sign/api/document-managment/get-details-of-a-particular-document.html
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoSign::Document::Facade ...>
  #   service.facade.request_name
  #   service.request_name
  #
  # GET /api/v1/requests/:id
  def call
    connection.get("requests/#{id}")
  end

  private

  def set_facade
    @facade = ZohoSign::Document::Facade.new(response.body['requests'])
  end
end
