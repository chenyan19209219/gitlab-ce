<script>
export default {
  props: {
    isExplore: {
      type: Boolean,
      default: false,
    },
    accessLevel: {
      type: Number, // TODO: double check
      default: 0,
    },
    humanAccess: {
      type: String, // TODO: double check
      default: '',
    },
  },
};
</script>
<template>
  <div>
    <!-- %span.metadata-info.visibility-icon.append-right-10.prepend-top-8.has-tooltip{ data: { container: 'body', placement: 'top' }, title: visibility_icon_description(project) }
    = visibility_level_icon(project.visibility_level, fw: true)

  <div if="isExplore"></div>
  - if explore_projects_tab? && project.repository.license
    %span.metadata-info.d-inline-flex.align-items-center.append-right-10.prepend-top-8
      = sprite_icon('scale', size: 14, css_class: 'append-right-4')
      = project.repository.license.name

  <div else></div>
  - if !explore_projects_tab? && access&.nonzero?
    -# haml-lint:disable UnnecessaryStringOutput
    = ' ' # prevent haml from eating the space between elements
    .metadata-info.prepend-top-8
    %span.user-access-role.d-block= Gitlab::Access.human_access(access)-->
    <span if="accessLevel" class="user-access-role d-block">{{humanAccess}}</span>
    <div class="metadata-info prepend-top-8">
      <span class="user-access-role d-block">Developer</span>
    </div>
  </div>
</template>
