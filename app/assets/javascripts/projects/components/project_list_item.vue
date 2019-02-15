<script>
/**
 * Renders a project list item
 */
export default {
  props: {
    project: {
      id: {
        type: Number,
        required: true,
      },
      name: {
        type: String,
        required: true,
      },
      name_with_namespace: {
        type: String,
        required: true,
      },
      path: {
        type: String,
        required: true,
      },
      path_with_namespace: {
        type: String,
        required: true,
      },
      created_at: {
        type: String,
        required: true,
      },
      default_branch: {
        type: String,
        required: true,
      },
      ssh_url_to_repo: {
        type: String,
        required: true,
      },
      http_url_to_repo: {
        type: String,
        required: true,
      },
      web_url: {
        type: String,
        required: true,
      },
      readme_url: {
        type: String,
        required: true,
      },
      avatar_url: {
        type: String,
        required: true,
      },
      star_count: {
        type: Number,
        required: true,
      },
      forks_count: {
        type: Number,
        required: true,
      },
      last_activity_at: {
        type: String,
        required: true,
      },
      namespace: {
        id: {
          type: Number,
          required: true,
        },
        name: {
          type: String,
          required: true,
        },
        path: {
          type: String,
          required: true,
        },
        kind: {
          type: String,
          required: true,
        },
        full_path: {
          type: String,
          required: true,
        },
      },
    },
  },
  components: {},
  computed: {},
};
</script>
<template>
  <!-- TODO: replace placeholder content -->
  <div v-if="project" class="project-details d-sm-flex flex-sm-fill align-items-center">
    <div class="flex-wrapper">
      <div class="d-flex align-items-center flex-wrap project-title">
        <h2 class="d-flex prepend-top-8">
          <a class="text-plain" href="/h5bp/html5-boilerplate">
            <span class="project-full-name append-right-8">
              <span class="namespace-name">{{project.namespace.name}}&nbsp;/</span>
              <span class="project-name">{{project.name}}</span>
            </span>
          </a>
        </h2>
        <span
          class="metadata-info visibility-icon append-right-10 prepend-top-8 has-tooltip"
          data-container="body"
          data-placement="top"
          title="Internal - The project can be accessed by any logged in user."
        >
          <i aria-hidden="true" data-hidden="true" class="fa fa-shield fa-fw"></i>
        </span>

        <div class="metadata-info prepend-top-8">
          <span class="user-access-role d-block">Developer</span>
        </div>
      </div>
      <div class="description d-none d-sm-block append-right-default">
        <p
          data-sourcepos="1:1-1:57"
          dir="auto"
        >Ullam voluptas velit laudantium dolores error architecto.</p>
      </div>
    </div>
    <div
      class="align-items-center align-items-sm-end controls d-flex flex-lg-row flex-shrink-0 flex-sm-column flex-wrap justify-content-lg-between"
    >
      <div class="icon-container d-flex align-items-center">
        <span
          class="d-flex align-items-center icon-wrapper stars has-tooltip"
          data-container="body"
          data-placement="top"
          title="Stars"
        >
          <svg class="s14 append-right-4">
            <use
              xlink:href="/assets/icons-24aaa921aa9e411162e6913688816c79861d0de4bee876cf6fc4c794be34ee91.svg#star"
            ></use>
          </svg>
          0
        </span>
        <a
          class="align-items-center icon-wrapper forks has-tooltip"
          title="Forks"
          data-container="body"
          data-placement="top"
          href="/h5bp/html5-boilerplate/forks"
        >
          <svg class="s14 append-right-4">
            <use
              xlink:href="/assets/icons-24aaa921aa9e411162e6913688816c79861d0de4bee876cf6fc4c794be34ee91.svg#fork"
            ></use>
          </svg>
          0
        </a>
        <a
          class="d-none d-xl-flex align-items-center icon-wrapper merge-requests has-tooltip"
          title="Merge Requests"
          data-container="body"
          data-placement="top"
          href="/h5bp/html5-boilerplate/merge_requests"
        >
          <svg class="s14 append-right-4">
            <use
              xlink:href="/assets/icons-24aaa921aa9e411162e6913688816c79861d0de4bee876cf6fc4c794be34ee91.svg#git-merge"
            ></use>
          </svg>
          1
        </a>
        <a
          class="d-none d-xl-flex align-items-center icon-wrapper issues has-tooltip"
          title="Issues"
          data-container="body"
          data-placement="top"
          href="/h5bp/html5-boilerplate/issues"
        >
          <svg class="s14 append-right-4">
            <use
              xlink:href="/assets/icons-24aaa921aa9e411162e6913688816c79861d0de4bee876cf6fc4c794be34ee91.svg#issues"
            ></use>
          </svg>
          8
        </a>
      </div>
      <div class="updated-note">
        <span>
          Updated
          <time
            class="js-timeago"
            title
            datetime="2019-02-05T09:45:29Z"
            data-toggle="tooltip"
            data-placement="top"
            data-container="body"
            data-tid="4"
            data-original-title="Feb 5, 2019 9:45am"
          >1 week ago</time>
        </span>
      </div>
    </div>
  </div>
</template>
