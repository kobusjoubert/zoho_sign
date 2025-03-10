# frozen_string_literal: true

require 'active_call'
require 'faraday'
require 'faraday/retry'
require 'faraday/logging/color_formatter'
require 'zeitwerk'

require_relative 'zoho_sign/version'

loader = Zeitwerk::Loader.for_gem.tap do |loader|
  loader.push_dir("#{__dir__}/zoho_sign/concerns", namespace: ZohoSign)
end

loader.setup

module ZohoSign
  class Error < StandardError; end

  class RequestError < Error
    include RequestErrorable
  end

  # 500..599
  class ServerError < RequestError; end

  # 400..499
  class ClientError < RequestError; end
  class BadRequestError < ClientError; end # 400
  class UnauthorizedError < ClientError; end # 401
  class ForbiddenError < ClientError; end # 403
  class ResourceNotFound < ClientError; end # 404
  class RequestTimeoutError < ClientError; end # 408
  class ConflictError < ClientError; end # 409
  class UnprocessableEntityError < ClientError; end # 422
  class TooManyRequestsError < ClientError; end # 429
end
