class GitlabPagesController < ActionController::Base
  include RoutableActions

  before_action :exact_pages_domain!
  before_action :find_project!

  attr_reader :project

  SUFFIX_REGEXP = /\.#{Regexp.escape(Settings.pages.host)}\z/i.freeze

  def show
    # TODO: Now take the rest of the path and ask workhorse to extract and show
    # the file in the artifact that it corresponds to, just like the "get a file
    # from inside the artifact" API does
    render plain: project.full_path
  end

  private

  # TODO: implement access control for pages \o/
  # This involves being an OAuth client against ourselves, kind of
  def can?(*args)
    true
  end

  def route_not_found
    head :not_found
  end

  # We have no content to show for this case. Perhaps in future, we can allow
  # admins to configure a pages site to use when this domain is reached.
  def exact_pages_domain!
    return unless request.host.downcase == Settings.pages.host.downcase

    route_not_found
  end

  # This must be determined from the subdomain (if any), plus path
  def find_project!
    @project =
      if SUFFIX_REGEXP.match?(request.host)
        toplevel_group = request.host.sub(SUFFIX_REGEXP, '')

        find_routable!(Project, toplevel_group + request.path)
      else
        PagesDomain.find_by(domain: request.host)&.project
      end

    route_not_found unless @project
  end
end
