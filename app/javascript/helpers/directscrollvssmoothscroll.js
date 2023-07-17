document.addEventListener('turbo:before-visit', event => {
  document.documentElement.style.scrollBehavior = 'auto';
});

document.addEventListener('turbo:load', event => {
  // Add a timeout to change the scroll behavior back to 'smooth' after the jump has happened.
  setTimeout(() => {
    document.documentElement.style.scrollBehavior = 'smooth';
  }, 0);
});

