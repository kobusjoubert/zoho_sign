# frozen_string_literal: true

class ZohoSign::CurrentUser::Facade
  attr_reader :account_id, :account_type, :api_credits_left, :api_documents_used, :automation_limit,
    :automation_used_count, :branding, :configurations, :country, :documents_used, :enable_old_viewer_page, :features,
    :first_name, :iam_photo_url, :is_admin, :is_api_account, :is_cloud_signing_allowed, :is_owner, :is_sign_trial,
    :is_trial, :is_visible_sign_option_allowed, :is_zoho_one, :language, :last_name, :license_type, :logo_url,
    :monthly_bulk_used, :monthly_signforms_used, :multiportal_enabled, :no_of_documents, :org_name, :organizations,
    :payment_url, :photo_url, :plan_edition, :plan_group, :profile, :profile_details, :send_mail_from,
    :show_api_warning_msg, :smtp_configured, :user_email, :user_id, :visible_sign_settings, :zo_users_url, :zooid,
    :zuid, :zsoid

  def initialize(hash)
    @account_id                     = hash['account_id']
    @account_type                   = hash['account_type']
    @api_credits_left               = hash['api_credits_left']
    @api_documents_used             = hash['api_documents_used']
    @automation_limit               = hash['automation_limit']
    @automation_used_count          = hash['automation_used_count']
    @branding                       = hash['branding']
    @configurations                 = hash['configurations']
    @country                        = hash['country']
    @documents_used                 = hash['documents_used']
    @enable_old_viewer_page         = hash['enable_old_viewer_page']
    @features                       = hash['features']
    @first_name                     = hash['first_name']
    @iam_photo_url                  = hash['IAM_photo_url']
    @is_admin                       = hash['is_admin']
    @is_api_account                 = hash['is_api_account']
    @is_cloud_signing_allowed       = hash['is_cloud_signing_allowed']
    @is_owner                       = hash['is_owner']
    @is_sign_trial                  = hash['is_sign_trial']
    @is_trial                       = hash['is_trial']
    @is_visible_sign_option_allowed = hash['is_visible_sign_option_allowed']
    @is_zoho_one                    = hash['is_zoho_one']
    @language                       = hash['language']
    @last_name                      = hash['last_name']
    @license_type                   = hash['license_type']
    @logo_url                       = hash['logo_url']
    @monthly_bulk_used              = hash['monthly_bulk_used']
    @monthly_signforms_used         = hash['monthly_signforms_used']
    @multiportal_enabled            = hash['multiportal_enabled']
    @no_of_documents                = hash['no_of_documents']
    @org_name                       = hash['org_name']
    @organizations                  = hash['organizations']
    @payment_url                    = hash['payment_url']
    @photo_url                      = hash['photo_url']
    @plan_edition                   = hash['plan_edition']
    @plan_group                     = hash['plan_group']
    @profile                        = hash['profile']
    @profile_details                = hash['profile_details']
    @send_mail_from                 = hash['send_mail_from']
    @show_api_warning_msg           = hash['show_api_warning_msg']
    @smtp_configured                = hash['smtp_configured']
    @user_email                     = hash['user_email']
    @user_id                        = hash['user_id']
    @visible_sign_settings          = hash['visible_sign_settings']
    @zo_users_url                   = hash['zo_users_url']
    @zooid                          = hash['zooid']
    @zuid                           = hash['ZUID']
    @zsoid                          = hash['ZSOID']
  end
end
