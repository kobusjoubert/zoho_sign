# frozen_string_literal: true

require 'active_call'
require 'active_call/api'
require 'faraday/multipart'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/active_call-zoho_sign.rb")
loader.ignore("#{__dir__}/zoho_sign/error.rb")
loader.collapse("#{__dir__}/zoho_sign/concerns")
loader.setup

require_relative 'zoho_sign/error'
require_relative 'zoho_sign/version'

module ZohoSign; end
