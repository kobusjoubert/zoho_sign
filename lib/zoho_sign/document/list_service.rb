# frozen_string_literal: true

class ZohoSign::Document::ListService < ZohoSign::BaseService
  include Enumerable

  # List documents.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::ListService.call.first
  #   service.request_name
  #
  #   service = ZohoSign::Document::ListService.call(limit: 10, offset: 1).each { _1 }
  #
  def call
    self
  end

  def each
    return to_enum(:each) unless block_given?

    @response = connection.get('requests', data: params)

    response.body['requests'].each do |hash|
      yield ZohoSign::Document::Facade.new(hash)
    end
  end

  private

  def params
    {
      page_context: {
        row_count: 10,
        start_index: 1,
        search_columns: {
          recipient_email: 'ashton@shopspa.co.za'
        },
        sort_column: 'created_time',
        sort_order: 'DESC'
      }
    }.to_json
  end
end
