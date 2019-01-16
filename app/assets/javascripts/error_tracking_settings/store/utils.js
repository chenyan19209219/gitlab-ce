export const transformBackendProject = ({
  slug,
  name,
  organization_name: organizationName,
  organization_slug: organizationSlug,
}) => ({
  id: organizationSlug + slug,
  slug,
  name,
  organizationName,
  organizationSlug,
});

export const transformFrontendSettings = ({ apiHost, enabled, token, selectedProject }) => ({
  api_host: apiHost || null,
  enabled,
  token: token || null,
  project: selectedProject
    ? {
        slug: selectedProject.slug,
        name: selectedProject.name,
        organization_name: selectedProject.organizationName,
        organization_slug: selectedProject.organizationSlug,
      }
    : null,
});
