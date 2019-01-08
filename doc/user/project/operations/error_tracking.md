# Error Tracking

> [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/169) in GitLab 11.8.

Error tracking provides a way to ingest and display error tracking in GitLab.

TODO: 1 sentence explanation of why it's useful to view errors in GitLab.

## Sentry error tracking

[Sentry](https://sentry.io/) is an open source error tracking system.

### Deploying Sentry

You may sign up to the cloud hosted https://sentry.io or deploy your own on-premise instance.

On-premise deployment instructions are detailed in the [Sentry docs](https://docs.sentry.io/server/installation/).

### Enabling Sentry

TODO: Potentially move this section to the admin docs

GitLab provides an easy way to connect to your Sentry instance from within your project.

1. Sign up to Sentry.io or [deploy your own](#deploying-sentry) Sentry instance
1. [Find or generate](https://docs.sentry.io/api/auth/) a Sentry auth token for your Sentry project
1. Navigate to your project’s **Settings > Operations** and provide the Sentry API URL and auth token
1. Click **Save changes** for the changes to take effect.
1. You can now visit **Operations > Error Tracking** in your project's sidebar to [view a list](#error-tracking-list) of Sentry errors

## Error Tracking List

The Error Tracking list may be found at **Operations > Error Tracking** in your project's sidebar.

TODO: Add screenshot
