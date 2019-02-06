import {
  transformBackendProject,
  transformFrontendSettings,
} from '~/error_tracking_settings/store/utils';
import {
  sampleBackendProject,
  normalizedProject,
  sampleFrontendSettings,
  transformedSettings,
} from '../mock';

describe('error tracking settings utils', () => {
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
