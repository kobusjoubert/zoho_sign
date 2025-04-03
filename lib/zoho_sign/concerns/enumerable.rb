# frozen_string_literal: true

module ZohoSign::Enumerable
  extend ActiveSupport::Concern

  included do
    include Enumerable

    attr_reader :path, :list_key, :facade_klass, :limit, :offset

    validates :path, :list_key, :facade_klass, presence: true
    validates :limit, presence: true, numericality: { greater_than_or_equal_to: 1 }
  end

  def initialize(path:, list_key:, facade_klass:, limit: Float::INFINITY, offset: 1)
    @path         = path
    @list_key     = list_key
    @facade_klass = facade_klass
    @limit        = limit
    @offset       = offset
  end

  def call
    self
  end

  def each
    return to_enum(:each) unless block_given?
    return if invalid?

    total = 0

    catch :list_end do
      loop do
        @response = connection.get(path, data: params.to_json)
        validate(:response)

        unless success?
          raise exception_for(response, errors) if bang?

          throw :list_end
        end

        response.body[list_key].each do |hash|
          yield facade_klass.new(hash)
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
        row_count:   max_limit_per_request,
        start_index: offset
      }
    }
  end

  def max_limit_per_request
    @_max_limit_per_request ||= limit.infinite? ? 100 : [limit, 100].min
  end
end
