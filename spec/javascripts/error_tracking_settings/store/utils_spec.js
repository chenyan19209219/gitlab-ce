import {
  transformBackendProject,
  transformFrontendSettings,
} from '~/error_tracking_settings/store/utils';

const normalizedProject = {
  id: 'organization_slugslug',
  name: 'name',
  slug: 'slug',
  organizationName: 'organization_name',
  organizationSlug: 'organization_slug',
};

const sampleBackendProject = {
  name: normalizedProject.name,
  slug: normalizedProject.slug,
  organization_name: normalizedProject.organizationName,
  organization_slug: normalizedProject.organizationSlug,
};

const sampleFrontendSettings = {
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

const transformedSettings = {
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

describe('ErrorTrackingSettings', () => {
  describe('data transform functions', () => {
    it('should transform a backend project successfully', () => {
      expect(transformBackendProject(sampleBackendProject)).toEqual(normalizedProject);
    });

    it('should transform settings successfully for the backend', () => {
      expect(transformFrontendSettings(sampleFrontendSettings)).toEqual(transformedSettings);
    });

    it('should transform empty values in the settings object to null', () => {
      const emptyFrontendSettingsObject = {
        ...sampleFrontendSettings,
        apiHost: '',
        token: '',
        selectedProject: null,
      };
      const transformedEmptySettingsObject = {
        ...transformedSettings,
        api_host: null,
        token: null,
        project: null,
      };

      expect(transformFrontendSettings(emptyFrontendSettingsObject)).toEqual(
        transformedEmptySettingsObject,
      );
    });
  });
});
