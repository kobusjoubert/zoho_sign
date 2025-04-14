# frozen_string_literal: true

class ZohoSign::Template::GetService < ZohoSign::BaseService
  attr_reader :id

  after_call :set_facade

  delegate_missing_to :@facade

  validates :id, presence: true

  def initialize(id:)
    @id = id
  end

  # Get a document.
  #
  # https://www.zoho.com/sign/api/template-managment/get-template-details.html
  #
  # ==== Examples
  #
  #   service = ZohoSign::Template::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoSign::Template::Facade ...>
  #   service.facade.template_name
  #   service.template_name
  #
  # GET /api/v1/templates/:id
  def call
    connection.get("templates/#{id}")
  end

  private

  def set_facade
    @facade = ZohoSign::Template::Facade.new(response.body['templates'])
  end
end
