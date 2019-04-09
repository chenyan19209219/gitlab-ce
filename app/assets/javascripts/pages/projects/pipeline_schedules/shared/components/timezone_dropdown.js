const defaultTimezone = { name: 'UTC', offset: 0 };

export const formatUtcOffset = offset => {
  const parsed = parseInt(offset, 10);
  if (Number.isNaN(parsed) || parsed === 0) {
    return `0`;
  }
  const prefix = offset > 0 ? '+' : '-';
  return `${prefix} ${Math.abs(offset / 3600)}`;
};

export const formatTimezone = item => `[UTC ${formatUtcOffset(item.offset)}] ${item.name}`;

const findTimezoneByName = (tzList = [], name = null) => {
  if (tzList.length && name && name.length) {
    return tzList.find(tz => tz.name === name);
  }
  return null;
};

const defaults = {
  $inputEl: null,
  $dropdownEl: null,
  onSelectTimezone: null,
};

export default class TimezoneDropdown {
  constructor({
    $dropdownEl,
    $inputEl,
    onSelectTimezone,
    displayFormat = item => item.name,
  } = defaults) {
    this.$dropdown = $dropdownEl;
    this.$dropdownToggle = this.$dropdown.find('.dropdown-toggle-text');
    this.$input = $inputEl;
    this.timezoneData = this.$dropdown.data('data');

    this.onSelectTimezone = onSelectTimezone;
    this.displayFormat = displayFormat;

    this.initialTimezone =
      findTimezoneByName(this.timezoneData, this.$input.val()) || defaultTimezone;

    this.initDefaultTimezone(); // TODO: this should look through the list of tz's provided and find the corresponding one
    this.initDropdown();
  }

  initDropdown() {
    this.$dropdown.glDropdown({
      data: this.timezoneData,
      filterable: true,
      selectable: true,
      toggleLabel: this.displayFormat,
      search: {
        fields: ['name'],
      },
      clicked: cfg => this.updateInputValue(cfg),
      text: item => formatTimezone(item),
    });

    this.setDropdownToggle(this.displayFormat(this.initialTimezone));
  }

  initDefaultTimezone() {
    if (!this.$input.val()) {
      this.$input.val(defaultTimezone.name);
    }
  }

  setDropdownToggle(dropdownText) {
    this.$dropdownToggle.text(dropdownText);
  }

  updateInputValue({ selectedObj, e }) {
    e.preventDefault();
    this.$input.val(selectedObj.identifier);
    if (this.onSelectTimezone) {
      this.onSelectTimezone({ selectedObj, e });
    }
  }
}
