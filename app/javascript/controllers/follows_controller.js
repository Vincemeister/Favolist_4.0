import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="follows"
export default class extends Controller {
  static targets = ["button"]


  connect() {
    console.log("Hello, Stimulus Follows controoler")
  }


  toggleFollow(event) {
    event.preventDefault();

    const button = event.currentTarget;
    if (!button) {
      console.log('event.currentTarget is null or undefined');
      return;
    }
    console.log("button:", button);
    console.log("classlist:", button.classList);

    // Get the URL and method from the button's data attributes
    const url = button.getAttribute('data-url');
    const method = button.getAttribute('data-method');

    // Make sure to replace 'your-token' and 'your-csrf-token' with your actual tokens
    fetch(url, {
      method: method,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': 'your-csrf-token',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin'
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      this.updateButton(data, button);
    })
    .catch(error => {
      console.error('Fetch Error:', error);
    });
  }


  updateButton(data, button) {
    // update button text
    button.textContent = data.newButtonText;

    // update button class
    button.className = '';
    let classes = data.newButtonClass.trim().replace(/\s+/g, ' ').split(' ');
    classes.forEach((cls) => {
      if (cls !== '') {
        button.classList.add(cls);
      }
    });

    // update button data attributes based on the data from the server
    // Assuming the server sends a new 'method' and 'path' for the button
    button.setAttribute('data-method', data.newMethod);
    button.setAttribute('data-path', data.newPath);
}







  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element.getAttribute('content')
  }
}
