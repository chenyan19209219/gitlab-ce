get '*path',
    to: 'gitlab_pages#show',
    format: false,
    constraints: ->(request) do
      # Ensure we match *exactly* the Pages domain, or any subdomain of it.
      request.host.downcase == Settings.pages.host.downcase ||
        GitlabPagesController::SUFFIX_REGEXP.match?(request.host)
    end

