# frozen_string_literal: true

class ZohoSign::Template::ListService < ZohoSign::BaseService
  SORT_COLUMNS = %w[template_name owner_first_name modified_time].freeze
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
  # https://www.zoho.com/sign/api/template-managment/get-template-list.html
  #
  # ==== Examples
  #
  #   service = ZohoSign::Template::ListService.call.first
  #   service.request_name
  #
  # If you don't provide the `limit` argument, multiple API requests will be made untill all records have been returned.
  # You could be rate limited, so use wisely.
  #
  #   ZohoSign::Template::ListService.call(offset: 11, limit: 10).each { _1 }
  #
  # Sort by column.
  #
  #   ZohoSign::Template::ListService.call(sort_column: 'template_name', sort_order: 'ASC').map { _1 }
  #
  # Filter by column.
  #
  #   ZohoSign::Template::ListService.call(search_columns: { template_name: 'Eric Template' }).map { _1 }
  #
  # Columns to sort and filter by are `template_name`, `owner_first_name` and `modified_time`.
  #
  # GET /api/v1/templates
  def initialize(offset: 1, limit: Float::INFINITY, sort_column: 'template_name', sort_order: 'DESC', search_columns: {})
    @sort_column    = sort_column
    @sort_order     = sort_order
    @search_columns = search_columns

    super(
      path:         'templates',
      list_key:     'templates',
      facade_klass: ZohoSign::Template::Facade,
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
