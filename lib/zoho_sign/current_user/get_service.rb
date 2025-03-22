# frozen_string_literal: true

class ZohoSign::CurrentUser::GetService < ZohoSign::BaseService
  after_call :set_facade

  delegate_missing_to :@facade

  def initialize; end

  # Get the current user.
  #
  # ==== Examples
  #
  #   service = ZohoSign::CurrentUser::GetService.call
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<ZohoSign::CurrentUser::Facade ...>
  #   service.facade.zsoid
  #   service.zsoid
  #
  # GET /api/v1/currentuser
  def call
    connection.get('currentuser')
  end

  private

  def set_facade
    @facade = ZohoSign::CurrentUser::Facade.new(response.body['users'])
  end
end
