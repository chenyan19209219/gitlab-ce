import { getParameterByName } from '../lib/utils/common_utils';

export default () => {
  const { protocol, host, pathname } = window.location;
  const shareBtn = document.querySelector('.js-share-btn');
  const embedBtn = document.querySelector('.js-embed-btn');
  const snippetUrlArea = document.querySelector('.js-snippet-url-area');
  const embedAction = document.querySelector('.js-embed-action');

  const secretParam = 'secret';
  const secretValue = getParameterByName(secretParam);
  const baseUrl = `${protocol}//${host + pathname}`;

  let urlArgs = '';

  if (secretValue) {
    urlArgs = `?${secretParam}=${secretValue}`;
  }

  const url = baseUrl + urlArgs;

  shareBtn.addEventListener('click', () => {
    shareBtn.classList.add('is-active');
    embedBtn.classList.remove('is-active');
    snippetUrlArea.value = url;
    embedAction.innerText = 'Share';
  });

  embedBtn.addEventListener('click', () => {
    embedBtn.classList.add('is-active');
    shareBtn.classList.remove('is-active');
    const scriptTag = `<script src="${url}.js"></script>`;
    snippetUrlArea.value = scriptTag;
    embedAction.innerText = 'Embed';
  });
};
