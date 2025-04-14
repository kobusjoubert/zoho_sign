# frozen_string_literal: true

class ZohoSign::Document::DeleteService < ZohoSign::BaseService
  attr_reader :id

  validates :id, presence: true

  def initialize(id:)
    @id = id
  end

  # Delete a document.
  #
  # https://www.zoho.com/sign/api/document-managment/delete-document.html
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::DeleteService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  # PUT /api/v1/requests/:id/delete
  def call
    connection.put("requests/#{id}/delete")
  end
end
