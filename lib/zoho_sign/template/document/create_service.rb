# frozen_string_literal: true

class ZohoSign::Template::Document::CreateService < ZohoSign::BaseService
  attr_reader :id, :data, :is_quicksend

  validates :id, :data, presence: true
  validates :is_quicksend, inclusion: { in: [true, false] }

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, data:, is_quicksend: false)
    @id           = id
    @data         = data
    @is_quicksend = is_quicksend
  end

  # Create a document from a template.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Template::Document::CreateService.call!(
  #     id: '',
  #     is_quicksend: true,
  #     data: {
  #       templates: {
  #         request_name: 'Request Document',
  #         field_data: {
  #           field_text_data: {
  #             'Full name' => 'Eric Cartman',
  #             'Email' => 'eric.cartman@example.com'
  #           },
  #           field_boolean_data: {
  #             'Agreed to terms' => true
  #           },
  #           field_date_data: {
  #             'Inception date' => '31/01/2025'
  #           }
  #         },
  #         actions: [{
  #           action_type: 'SIGN',
  #           recipient_email: 'eric.cartman@example.com',
  #           recipient_name: 'Eric Cartman',
  #           verify_recipient: false,
  #           delivery_mode: 'EMAIL',
  #           action_id: '',
  #           role: 'Client'
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
  #   service.facade # => #<ZohoSign::Temlate::Document::Facade ...>
  #   service.facade.request_name
  #   service.request_name
  #
  # POST /api/v1/templates/:id/createdocument
  def call
    connection.post("templates/#{id}/createdocument", **params)
  end

  private

  def params
    {
      data:         data.to_json,
      is_quicksend: is_quicksend
    }
  end

  def set_facade
    @facade = ZohoSign::Template::Document::Facade.new(response.body['requests'])
  end
end
