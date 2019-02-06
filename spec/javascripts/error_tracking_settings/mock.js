export const projectList = [
  {
    id: 1,
    name: 'name',
    slug: 'slug',
    organizationName: 'organizationName',
    organizationSlug: 'organizationSlug',
  },
  {
    id: 2,
    name: 'name2',
    slug: 'slug2',
    organizationName: 'organizationName2',
    organizationSlug: 'organizationSlug2',
  },
];

export const staleProject = {
  id: 3,
  name: 'staleName',
  slug: 'staleSlug',
  organizationName: 'staleOrganizationName',
  organizationSlug: 'staleOrganizationSlug',
};

export const normalizedProject = {
  id: 'organization_slugslug',
  name: 'name',
  slug: 'slug',
  organizationName: 'organization_name',
  organizationSlug: 'organization_slug',
};

export const sampleBackendProject = {
  name: normalizedProject.name,
  slug: normalizedProject.slug,
  organization_name: normalizedProject.organizationName,
  organization_slug: normalizedProject.organizationSlug,
};

export const sampleFrontendSettings = {
  apiHost: 'apiHost',
  enabled: true,
  token: 'token',
  selectedProject: {
    slug: normalizedProject.slug,
    name: normalizedProject.name,
    organizationName: normalizedProject.organizationName,
    organizationSlug: normalizedProject.organizationSlug,
  },
};

export const transformedSettings = {
  api_host: 'apiHost',
  enabled: true,
  token: 'token',
  project: {
    slug: normalizedProject.slug,
    name: normalizedProject.name,
    organization_name: normalizedProject.organizationName,
    organization_slug: normalizedProject.organizationSlug,
  },
};
