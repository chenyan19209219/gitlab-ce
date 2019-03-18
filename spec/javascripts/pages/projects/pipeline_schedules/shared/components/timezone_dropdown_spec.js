import {
  formatUtcOffset,
  formatTimezone,
} from '~/pages/projects/pipeline_schedules/shared/components/timezone_dropdown';

describe('Timezone Dropdown', function() {
  describe('formatUtcOffset', () => {
    it('will convert negative utc offsets in seconds to hours and minutes', () => {
      expect(formatUtcOffset(-21600)).toEqual('- 6');
    });

    it('will convert positive utc offsets in seconds to hours and minutes', () => {
      expect(formatUtcOffset(25200)).toEqual('+ 7');
      expect(formatUtcOffset(49500)).toEqual('+ 13.75');
    });

    it('will return NaN for bad input', () => {
      ['BLAH', '$%$%', ['an', 'array'], { some: '', object: '' }].forEach(inp => {
        expect(formatUtcOffset(inp)).toEqual(' NaN');
      });
    });

    it('will return 0 for empty input', () => {
      expect(formatUtcOffset('')).toEqual(' 0');
    });
  });

  describe('formatTimezone', () => {
    it('will format a given timezone and offset for display', () => {
      expect(
        formatTimezone({
          name: 'Chatham Is.',
          offset: 49500,
          identifier: 'Pacific/Chatham',
        }),
      ).toEqual('[UTC + 13.75] Chatham Is.');

      expect(
        formatTimezone({
          name: 'Saskatchewan',
          offset: -21600,
          identifier: 'America/Regina',
        }),
      ).toEqual('[UTC - 6] Saskatchewan');
    });
  });
});
