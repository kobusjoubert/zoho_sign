# frozen_string_literal: true

class ZohoSign::Document::ListService < ZohoSign::BaseService
  SORT_COLUMNS = %w[request_name folder_name owner_full_name recipient_email form_name created_time].freeze
  SORT_ORDERS  = %w[ASC DESC].freeze

  include ZohoSign::Enumerable

  attr_reader :sort_column, :sort_order, :search_columns

  validates :sort_order, inclusion: { in: SORT_ORDERS, message: "Sort order must be one of #{SORT_ORDERS.join(', ')}" }

  validates :sort_column, inclusion: {
    in:      SORT_COLUMNS,
    message: "Sort column must be one of #{SORT_COLUMNS.join(', ')}"
  }

  validate do
    next if search_columns.empty?
    next if (SORT_COLUMNS | search_columns.keys.map(&:to_s)).size == SORT_COLUMNS.size

    errors.add(:search_columns, "keys must be one of #{SORT_COLUMNS.join(', ')}")
    throw :abort
  end

  # List documents.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Document::ListService.call.first
  #   service.request_name
  #
  # If you don't provide the `limit` argument, multiple API requests will be made untill all records have been returned.
  # You could be rate limited, so use wisely.
  #
  #   ZohoSign::Document::ListService.call(offset: 11, limit: 10).each { _1 }
  #
  # Sort by column.
  #
  #   ZohoSign::Document::ListService.call(sort_column: 'recipient_email', sort_order: 'ASC').map { _1 }
  #
  # Filter by column.
  #
  #   ZohoSign::Document::ListService.call(search_columns: { recipient_email: 'eric.cartman@example.com' }).map { _1 }
  #
  # Columns to sort and filter by are `request_name`, `folder_name`, `owner_full_name`, `recipient_email`, `form_name`
  # and `created_time`.
  #
  # GET /api/v1/requests
  def initialize(offset: 1, limit: Float::INFINITY, sort_column: 'created_time', sort_order: 'DESC', search_columns: {})
    @sort_column    = sort_column
    @sort_order     = sort_order
    @search_columns = search_columns

    super(
      path:         'requests',
      list_key:     'requests',
      facade_klass: ZohoSign::Document::Facade,
      limit:        limit,
      offset:       offset
    )
  end

  private

  def params
    @_params ||= {
      page_context: {
        row_count:      max_limit_per_request,
        start_index:    offset,
        search_columns: search_columns,
        sort_column:    sort_column,
        sort_order:     sort_order
      }
    }
  end
end
