import $ from 'jquery';
import Cookies from 'js-cookie';
import _ from 'underscore';
import bp from './breakpoints';

export default class ContextualSidebar {
  #cookieKey = 'sidebar_collapsed';
  #cookieDuration = 365 * 10;
  #styleClass = 'sidebar-collapsed';

  constructor() {
    this.$sidebar = $('.nav-sidebar');
    this.behaviourClass = 'js-sidebar-collapsed';
    this.classes = `${this.#styleClass} ${this.behaviourClass}`;
  }

  toggle(shouldCollapse = !this.$sidebar.hasClass(this.behaviourClass), saveCookie) {
    const isMobile = bp.is('xs', 'sm');

    this.$sidebar.toggleClass(this.classes, shouldCollapse);
    this.$page.toggleClass('page-with-icon-sidebar', isMobile ? true : shouldCollapse);
    this.$overlay.toggleClass('mobile-nav-open', isMobile ? !shouldCollapse : false);

    if (saveCookie) this.#setCookie(shouldCollapse);
  }

  retoggle() {
    this.toggle(this.$sidebar.hasClass(this.behaviourClass));
  }

  open() {
    this.toggle(false);
  }

  close() {
    this.toggle(true);
  }

  render() {
    if (!this.$sidebar.length) return;

    this.#initDomElements();
    this.#bindEvents();

    this.retoggle();
  }

  #initDomElements() {
    this.$page = $('.layout-page');

    this.$overlay = $('.mobile-overlay');
    this.$openSidebar = $('.toggle-mobile-nav');
    this.$closeSidebar = $('.close-nav-button');
    this.$sidebarToggle = $('.js-toggle-sidebar');
  }

  #bindEvents() {
    this.$openSidebar.on('click', () => this.open());
    this.$closeSidebar.on('click', () => this.close());
    this.$overlay.on('click', () => this.close());
    this.$sidebarToggle.on('click', () => this.toggle(undefined, true));

    $(window).on('resize', _.debounce(() => this.#reset(), 300));
  }

  #reset() {
    const before = bp.getBreakpointSize();
    const after = bp.reset().getBreakpointSize();

    if (before !== after) this.retoggle();
  }

  #setCookie(value) {
    if (bp.isNot('xl')) return;

    Cookies.set(this.#cookieKey, value, { expires: this.#cookieDuration });
  }
}
