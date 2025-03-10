# frozen_string_literal: true

class ZohoSign::Document::Facade
  attr_reader :request_status, :notes, :attachments, :reminder_period, :owner_id, :description, :request_name,
    :modified_time, :action_time, :is_deleted, :expiration_days, :is_sequential, :sign_submitted_time, :templates_used,
    :owner_first_name, :sign_percentage, :expire_by, :is_expiring, :owner_email, :created_time, :email_reminders,
    :document_ids, :self_sign, :document_fields, :folder_name, :template_ids, :in_process, :validity,
    :request_type_name, :visible_sign_settings, :folder_id, :request_id, :zsdocumentid, :request_type_id,
    :owner_last_name, :actions, :attachment_size

  def initialize(hash)
    @request_status        = hash['request_status']
    @notes                 = hash['notes']
    @attachments           = hash['attachments']
    @reminder_period       = hash['reminder_period']
    @owner_id              = hash['owner_id']
    @description           = hash['description']
    @request_name          = hash['request_name']
    @modified_time         = hash['modified_time']
    @action_time           = hash['action_time']
    @is_deleted            = hash['is_deleted']
    @expiration_days       = hash['expiration_days']
    @is_sequential         = hash['is_sequential']
    @sign_submitted_time   = hash['sign_submitted_time']
    @templates_used        = hash['templates_used']
    @owner_first_name      = hash['owner_first_name']
    @sign_percentage       = hash['sign_percentage']
    @expire_by             = hash['expire_by']
    @is_expiring           = hash['is_expiring']
    @owner_email           = hash['owner_email']
    @created_time          = hash['created_time']
    @email_reminders       = hash['email_reminders']
    @document_ids          = hash['document_ids']
    @self_sign             = hash['self_sign']
    @document_fields       = hash['document_fields']
    @folder_name           = hash['folder_name']
    @template_ids          = hash['template_ids']
    @in_process            = hash['in_process']
    @validity              = hash['validity']
    @request_type_name     = hash['request_type_name']
    @visible_sign_settings = hash['visible_sign_settings']
    @folder_id             = hash['folder_id']
    @request_id            = hash['request_id']
    @zsdocumentid          = hash['zsdocumentid']
    @request_type_id       = hash['request_type_id']
    @owner_last_name       = hash['owner_last_name']
    @actions               = hash['actions']
    @attachment_size       = hash['attachment_size']
  end
end
