/*
 * Breakpoint values should be updated to Bootstrap 4 values
 *
 * The BS4 `xl` property has been added ahead of this refactor
 * and temporarily duplicates the existing BS3 `lg` property.
 *
 * https://gitlab.com/gitlab-org/gitlab-ce/issues/5674
 */
export const breakpoints = {
  xl: 1200,
  lg: 1200,
  md: 992,
  sm: 768,
  xs: 0,
};

const BreakpointInstance = {
  memoWindowWidth: undefined,
  windowWidth() {
    return (this.memoWindowWidth = this.memoWindowWidth || window.innerWidth);
  },
  memoBreakpointSize: undefined,
  getBreakpointSize() {
    if (this.memoBreakpointSize) return this.memoBreakpointSize;

    const windowWidth = this.windowWidth();
    const breakpoint = Object.keys(breakpoints).find(key => windowWidth > breakpoints[key]);

    return (this.memoBreakpointSize = breakpoint);
  },

  reset() {
    this.memoWindowWidth = undefined;
    this.memoBreakpointSize = undefined;

    return this;
  },

  is(...testBreakpoints) {
    const actual = this.getBreakpointSize();
    const testLength = testBreakpoints.length - 1;

    const regexpString = testBreakpoints.reduce((accum, bp, index) => {
      accum += bp;
      if (index !== testLength) accum += '|';
      return accum;
    }, '');

    return new RegExp(`^(${regexpString})$`).test(actual);
  },

  isNot(...testBreakpoints) {
    return !this.is(...testBreakpoints);
  },
};

export default BreakpointInstance;
