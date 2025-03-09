# frozen_string_literal: true

require 'zeitwerk'

require_relative 'zoho_sign/version'

loader = Zeitwerk::Loader.for_gem
loader.setup

module ZohoSign
  class Error < StandardError; end
end
