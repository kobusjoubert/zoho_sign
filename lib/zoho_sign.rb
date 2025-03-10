# frozen_string_literal: true

require 'active_call'
require 'faraday'
require 'faraday/retry'
require 'faraday/logging/color_formatter'
require 'zeitwerk'

require_relative 'zoho_sign/version'

loader = Zeitwerk::Loader.for_gem
loader.push_dir("#{__dir__}/zoho_sign/concerns", namespace: ZohoSign)
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

  # 400
  class BadRequestError < ClientError; end

  # 401
  class UnauthorizedError < ClientError; end

  # 403
  class ForbiddenError < ClientError; end

  # 404
  class ResourceNotFound < ClientError; end

  # 408
  class RequestTimeoutError < ClientError; end

  # 409
  class ConflictError < ClientError; end

  # 422
  class UnprocessableEntityError < ClientError; end

  # 429
  class TooManyRequestsError < ClientError; end
end
