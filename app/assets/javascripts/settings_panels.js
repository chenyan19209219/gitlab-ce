import $ from 'jquery';
import { __ } from './locale';

function expandSection($section, text = null) {
  $section
    .find('.js-settings-toggle:not(.js-settings-toggle-trigger-only)')
    .text(text || __('Collapse'));

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
  $section
    .find('.js-settings-toggle:not(.js-settings-toggle-trigger-only)')
    .text(text || __('Expand'));

  $section.find('.settings-content').on('scroll.expandSection', () => expandSection($section));
  $section.removeClass('expanded');
  if (!$section.hasClass('no-animate')) {
    $section
      .addClass('animating')
      .one('animationend.animateSection', () => $section.removeClass('animating'));
  }
}

function toggleSection($section, opts) {
  $section.removeClass('no-animate');
  if ($section.hasClass('expanded')) {
    closeSection($section, opts.collapsedText);
  } else {
    expandSection($section, opts.expandedText);
  }
}

// TODO: How does custom text affect translations
function updateText($section, text = '') {
  $section
    .find('.js-settings-toggle:not(.js-settings-toggle-trigger-only)')
    .text(text || __('Expand'));
}

export default function initSettingsPanels(
  opts = { expandedText: 'Expand', collapsedText: 'Collapse' },
) {
  $('.settings').each((i, elm) => {
    const $section = $(elm);
    $section.on('click.toggleSection', '.js-settings-toggle', () => toggleSection($section, opts));

    if (!$section.hasClass('expanded')) {
      $section.find('.settings-content').on('scroll.expandSection', () => {
        $section.removeClass('no-animate');
        expandSection($section, opts.collapsedText);
      });
    } else {
      updateText($section, opts.expandedText);
    }
  });

  if (window.location.hash) {
    const $target = $(window.location.hash);
    if ($target.length && $target.hasClass('settings')) {
      expandSection($target);
    }
  }
}
