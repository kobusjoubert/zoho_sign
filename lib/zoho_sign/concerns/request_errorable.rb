# frozen_string_literal: true

module ZohoSign::RequestErrorable
  extend ActiveSupport::Concern

  included do
    attr_reader :response
  end

  def initialize(response = nil, message = nil)
    @response = response
    message ||= response ? "#{response.status} #{response.reason_phrase}: #{response.body}" : 'Request failed'
    super(message)
  end
end
