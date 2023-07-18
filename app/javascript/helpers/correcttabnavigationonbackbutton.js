import * as Bootstrap from 'bootstrap';


document.addEventListener('turbo:load', event => {
  const urlParams = new URLSearchParams(window.location.search);
  const tabId = urlParams.get('tab');
  const tabElement = document.getElementById(tabId);

  if (tabElement) {
    const tab = new Bootstrap.Tab(tabElement);
    tab.show();
  }
});
