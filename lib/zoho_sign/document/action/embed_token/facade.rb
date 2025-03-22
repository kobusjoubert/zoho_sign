# frozen_string_literal: true

class ZohoSign::Document::Action::EmbedToken::Facade
  attr_reader :sign_url

  def initialize(hash)
    @sign_url = hash['sign_url']
  end
end
