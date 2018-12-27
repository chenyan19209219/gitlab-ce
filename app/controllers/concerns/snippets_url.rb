# frozen_string_literal: true

module SnippetsUrl
  extend ActiveSupport::Concern

  private

  attr_reader :snippet

  def authorize_secret_snippet!
    if snippet_has_secret?
      return if secrets_match?

      return render_404
    end

    current_user ? render_404 : authenticate_user!
  end

  def snippet_has_secret?
    snippet&.secret?
  end

  def secrets_match?
    ActiveSupport::SecurityUtils.variable_size_secure_compare(params[:secret], snippet.secret)
  end

  def ensure_complete_url
    redirect_to complete_url if redirect_to_complete_url?
  end

  def redirect_to_complete_url?
    return unless snippet_has_secret?
    return unless request.query_parameters['secret']

    !ActiveSupport::SecurityUtils.variable_size_secure_compare(request.query_parameters['secret'], snippet.secret)
  end

  def complete_url
    @complete_url ||= begin
      url = current_url.clone
      query_hash = current_url_query_hash.clone
      query_hash['secret'] = snippet.secret

      url.tap do |u|
        u.query = query_hash.to_query
      end.to_s
    end
  end

  def current_url
    @current_url ||= URI.parse(request.original_url)
  end

  def current_url_query_hash
    @current_url_query_hash ||= Rack::Utils.parse_nested_query(current_url.query)
  end
end
