# frozen_string_literal: true

class ZohoSign::Document::CreateService < ZohoSign::BaseService
  attr_reader :data, :file, :file_content_type, :file_name

  validates :file, :file_content_type, :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(data:, file:, file_content_type:, file_name: nil)
    @file              = file
    @file_content_type = file_content_type
    @file_name         = file_name
    @data              = data
  end

  # Create a document.
  #
  # https://www.zoho.com/sign/api/document-managment/create-document.html
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::CreateService.call(
  #     file: '/path/to/file.pdf', # or File.open('/path/to/file.pdf')
  #     file_name: 'file.pdf',
  #     file_content_type: 'application/pdf',
  #     data: {
  #       requests: {
  #         request_name: 'Name',
  #         is_sequential: false,
  #         actions: [{
  #           action_type: 'SIGN',
  #           recipient_email: 'eric.cartman@example.com',
  #           recipient_name: 'Eric Cartman',
  #           verify_recipient: true,
  #           verification_type: 'EMAIL'
  #         }]
  #       }
  #     }
  #   )
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
  # POST /api/v1/requests
  def call
    connection.post('requests', **params)
  end

  private

  def params
    {
      file: Faraday::Multipart::FilePart.new(file, file_content_type, file_name),
      data: data.to_json
    }
  end

  def set_facade
    @facade = ZohoSign::Document::Facade.new(response.body['requests'])
  end
end
