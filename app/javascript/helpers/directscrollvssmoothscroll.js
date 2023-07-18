import * as Bootstrap from 'bootstrap';

document.addEventListener('turbo:before-visit', event => {
  document.documentElement.style.scrollBehavior = 'auto';
});

document.addEventListener('turbo:load', event => {
  // Add a timeout to change the scroll behavior back to 'smooth' after the jump has happened.
  setTimeout(() => {
    document.documentElement.style.scrollBehavior = 'smooth';
  }, 0);
});



// Separate turbo:load event listener for tabs
document.addEventListener('turbo:load', event => {
  const urlParams = new URLSearchParams(window.location.search);
  const tabId = urlParams.get('tab');
  const tabElement = document.getElementById(tabId);

  if (tabElement) {
    const tab = new Bootstrap.Tab(tabElement);
    tab.show();
  }
});
