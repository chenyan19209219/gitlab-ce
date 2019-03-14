import Vue from 'vue';
import pipelineTriggererComp from '~/pipelines/components/pipeline_triggerer.vue';

describe('Pipeline Triggerer Component', () => {
  let PipelineTriggererComponent;

  beforeEach(() => {
    PipelineTriggererComponent = Vue.extend(pipelineTriggererComp);
  });

  it('should render a table cell', () => {
    const component = new PipelineTriggererComponent({
      propsData: {
        pipeline: {
          id: 1,
          path: 'foo',
          flags: {},
        },
        autoDevopsHelpPath: 'foo',
      },
    }).$mount();

    expect(component.$el.getAttribute('class')).toContain('table-section');
  });

  it('should render triggerer information when triggerer is provided', () => {
    const mockData = {
      pipeline: {
        id: 1,
        path: 'foo',
        flags: {},
        user: {
          web_url: '/',
          name: 'foo',
          avatar_url: '/',
          path: '/',
        },
      },
      autoDevopsHelpPath: 'foo',
    };
    const component = new PipelineTriggererComponent({ propsData: mockData }).$mount();

    const image = component.$el.querySelector('.js-pipeline-url-user img');
    const link = component.$el.querySelector('.js-pipeline-url-user');
    const tooltip = component.$el.querySelector(
      '.js-pipeline-url-user .js-user-avatar-image-toolip',
    );

    expect(image.getAttribute('src')).toEqual(`${mockData.pipeline.user.avatar_url}?width=26`);
    expect(link.getAttribute('href')).toEqual(mockData.pipeline.user.web_url);
    expect(tooltip.textContent.trim()).toEqual(mockData.pipeline.user.name);
  });

  it('should render "API" when no triggerer is provided', () => {
    const component = new PipelineTriggererComponent({
      propsData: {
        pipeline: {
          id: 1,
          path: 'foo',
          flags: {},
        },
        autoDevopsHelpPath: 'foo',
      },
    }).$mount();

    expect(component.$el.querySelector('.js-pipeline-url-api').textContent.trim()).toEqual('API');
  });
});
