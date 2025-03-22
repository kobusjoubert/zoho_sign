# frozen_string_literal: true

class ZohoSign::Template::Document::Facade
  attr_reader :action_time, :actions, :created_time, :description, :document_fields, :document_ids, :email_reminders,
    :expiration_days, :expire_by, :folder_id, :folder_name, :in_process, :is_deleted, :is_expiring, :is_sequential,
    :modified_time, :notes, :owner_email, :owner_first_name, :owner_id, :owner_last_name, :reminder_period, :request_id,
    :request_name, :request_status, :request_type_id, :request_type_name, :self_sign, :sign_percentage,
    :sign_submitted_time, :template_ids, :templates_used, :validity, :visible_sign_settings, :zsdocumentid

  def initialize(hash)
    @action_time           = hash['action_time']
    @actions               = hash['actions']
    @created_time          = hash['created_time']
    @description           = hash['description']
    @document_fields       = hash['document_fields']
    @document_ids          = hash['document_ids']
    @email_reminders       = hash['email_reminders']
    @expiration_days       = hash['expiration_days']
    @expire_by             = hash['expire_by']
    @folder_id             = hash['folder_id']
    @folder_name           = hash['folder_name']
    @in_process            = hash['in_process']
    @is_deleted            = hash['is_deleted']
    @is_expiring           = hash['is_expiring']
    @is_sequential         = hash['is_sequential']
    @modified_time         = hash['modified_time']
    @notes                 = hash['notes']
    @owner_email           = hash['owner_email']
    @owner_first_name      = hash['owner_first_name']
    @owner_id              = hash['owner_id']
    @owner_last_name       = hash['owner_last_name']
    @reminder_period       = hash['reminder_period']
    @request_id            = hash['request_id']
    @request_name          = hash['request_name']
    @request_status        = hash['request_status']
    @request_type_id       = hash['request_type_id']
    @request_type_name     = hash['request_type_name']
    @self_sign             = hash['self_sign']
    @sign_percentage       = hash['sign_percentage']
    @sign_submitted_time   = hash['sign_submitted_time']
    @template_ids          = hash['template_ids']
    @templates_used        = hash['templates_used']
    @validity              = hash['validity']
    @visible_sign_settings = hash['visible_sign_settings']
    @zsdocumentid          = hash['zsdocumentid']
  end
end
