# frozen_string_literal: true

class ZohoSign::Template::ListService < ZohoSign::BaseService
  SORT_COLUMNS = %w[template_name owner_first_name modified_time].freeze
  SORT_ORDERS  = %w[ASC DESC].freeze

  include Enumerable

  attr_reader :limit, :offset, :sort_column, :sort_order, :search_columns

  validates :limit, presence: true, numericality: { greater_than_or_equal_to: 1 }
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

  def initialize(limit: Float::INFINITY, offset: 1, sort_column: 'template_name', sort_order: 'DESC', search_columns: {})
    @limit          = limit
    @offset         = offset
    @sort_column    = sort_column
    @sort_order     = sort_order
    @search_columns = search_columns
  end

  # List documents.
  #
  # ==== Examples
  #
  #   service = ZohoSign::Template::ListService.call.first
  #   service.request_name
  #
  #   ZohoSign::Template::ListService.call(offset: 11, limit: 10).each { _1 }
  #   ZohoSign::Template::ListService.call(sort_column: 'template_name', sort_order: 'ASC').each { _1 }
  #   ZohoSign::Template::ListService.call(search_columns: { template_name: 'Eric Template' }).each { _1 }
  #
  # GET /api/v1/templates
  def call
    self
  end

  def each
    return to_enum(:each) unless block_given?
    return if invalid?

    total = 0

    catch :list_end do
      loop do
        @response = connection.get('templates', data: params.to_json)
        validate(:response)

        unless success?
          raise exception_for(response, errors) if bang?

          throw :list_end
        end

        response.body['templates'].each do |hash|
          yield ZohoSign::Template::Facade.new(hash)
          total += 1
          throw :list_end if total >= limit
        end

        break unless response.body.dig('page_context', 'has_more_rows')

        @_params[:page_context][:start_index] += max_limit_per_request
      end
    end
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

  def max_limit_per_request
    @_max_limit_per_request ||= limit.infinite? ? 100 : [limit, 100].min
  end
end
