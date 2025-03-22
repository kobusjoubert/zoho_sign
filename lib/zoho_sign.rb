# frozen_string_literal: true

require 'active_call'
require 'faraday'
require 'faraday/retry'
require 'faraday/multipart'
require 'faraday/logging/color_formatter'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/zoho_sign/error.rb")
loader.collapse("#{__dir__}/zoho_sign/concerns")
loader.setup

require_relative 'zoho_sign/error'
require_relative 'zoho_sign/version'

module ZohoSign; end

ActiveSupport.on_load(:i18n) do
  I18n.load_path << File.expand_path('zoho_sign/locale/en.yml', __dir__)
end
