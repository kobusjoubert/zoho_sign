# frozen_string_literal: true

class ZohoSign::Template::Facade
  attr_reader :actions, :created_time, :description, :document_ids, :document_fields, :email_reminders,
    :expiration_days, :folder_id, :folder_name, :is_deleted, :is_sequential, :modified_time, :notes, :owner_email,
    :owner_first_name, :owner_id, :owner_last_name, :reminder_period, :request_type_id, :request_type_name,
    :signform_count, :template_id, :template_name, :validity

  def initialize(hash)
    @actions           = hash['actions']
    @created_time      = hash['created_time']
    @description       = hash['description']
    @document_fields   = hash['document_fields']
    @document_ids      = hash['document_ids']
    @email_reminders   = hash['email_reminders']
    @expiration_days   = hash['expiration_days']
    @folder_id         = hash['folder_id']
    @folder_name       = hash['folder_name']
    @is_deleted        = hash['is_deleted']
    @is_sequential     = hash['is_sequential']
    @modified_time     = hash['modified_time']
    @notes             = hash['notes']
    @owner_email       = hash['owner_email']
    @owner_first_name  = hash['owner_first_name']
    @owner_id          = hash['owner_id']
    @owner_last_name   = hash['owner_last_name']
    @reminder_period   = hash['reminder_period']
    @request_type_id   = hash['request_type_id']
    @request_type_name = hash['request_type_name']
    @signform_count    = hash['signform_count']
    @template_id       = hash['template_id']
    @template_name     = hash['template_name']
    @validity          = hash['validity']
  end
end
