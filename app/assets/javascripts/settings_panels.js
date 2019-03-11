import $ from 'jquery';
import { __ } from './locale';

const DEFAULT_OPTS = { collapsedPanelText: __('Expand'), expandedPanelText: __('Collapse') };

function updateText($section, text = '') {
  $section.find('.js-settings-toggle:not(.js-settings-toggle-trigger-only)').text(text);
}

function expandSection($section, text = null) {
  updateText($section, text || DEFAULT_OPTS.expandedPanelText);

  $section
    .find('.settings-content')
    .off('scroll.expandSection')
    .scrollTop(0);
  $section.addClass('expanded');
  if (!$section.hasClass('no-animate')) {
    $section
      .addClass('animating')
      .one('animationend.animateSection', () => $section.removeClass('animating'));
  }
}

function closeSection($section, text = null) {
  updateText($section, text || DEFAULT_OPTS.collapsedPanelText);

  $section.find('.settings-content').on('scroll.expandSection', () => expandSection($section));
  $section.removeClass('expanded');
  if (!$section.hasClass('no-animate')) {
    $section
      .addClass('animating')
      .one('animationend.animateSection', () => $section.removeClass('animating'));
  }
}

function toggleSection($section, opts = DEFAULT_OPTS) {
  $section.removeClass('no-animate');
  if ($section.hasClass('expanded')) {
    closeSection($section, opts.collapsedPanelText);
  } else {
    expandSection($section, opts.expandedPanelText);
  }
}

export default function initSettingsPanels(opts = DEFAULT_OPTS) {
  $('.settings').each((i, elm) => {
    const $section = $(elm);
    $section.on('click.toggleSection', '.js-settings-toggle', () => toggleSection($section, opts));

    if (!$section.hasClass('expanded')) {
      $section.find('.settings-content').on('scroll.expandSection', () => {
        $section.removeClass('no-animate');
        expandSection($section, opts.expandedPanelText);
      });
    } else {
      updateText($section, opts.expandedPanelText);
    }
  });

  if (window.location.hash) {
    const $target = $(window.location.hash);
    if ($target.length && $target.hasClass('settings')) {
      expandSection($target);
    }
  }
}
