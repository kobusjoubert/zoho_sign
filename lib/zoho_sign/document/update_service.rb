# frozen_string_literal: true

class ZohoSign::Document::UpdateService < ZohoSign::BaseService
  attr_reader :id, :data

  validates :id, :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, data:)
    @id   = id
    @data = data
  end

  # Update a document.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::UpdateService.call(
  #     id: '',
  #     data: {
  #       requests: {
  #         request_name: 'Name Updated',
  #         actions: [{
  #           action_id: '',
  #           action_type: 'SIGN',
  #           recipient_email: 'stan.marsh@example.com',
  #           recipient_name: 'Stan Marsh'
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
  # PUT /api/v1/requests/:id
  def call
    connection.put("requests/#{id}", **params)
  end

  private

  def params
    {
      data: data.to_json
    }
  end

  def set_facade
    @facade = ZohoSign::Document::Facade.new(response.body['requests'])
  end
end
