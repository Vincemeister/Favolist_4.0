import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="follows"
export default class extends Controller {
  static targets = ["button"]


  connect() {
    console.log("Hello, Stimulus Follows controoler")
  }


  toggleFollow(event) {
    event.preventDefault();
    // const iteratingFor = button.getAttribute('data-iterating-for');


    const button = event.currentTarget;
    if (!button) {
      console.log('event.currentTarget is null or undefined');
      return;
    }


    // Get the URL and method from the button's data attributes
    const url = button.getAttribute('data-url');
    const method = button.getAttribute('data-method');


    console.log(url)
    console.log(method)
    console.log(button)
    console.log(button.getAttribute('data-path'))
    console.log(event.currentTarget.action)

    // Make sure to replace 'your-token' and 'your-csrf-token' with your actual tokens
    fetch(url, {
      method: method,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.getMetaValue('csrf-token'), // here

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
      this.displayFlash(data.flash);
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
    button.setAttribute('data-url', data.newPath);
  }








  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element.getAttribute('content')
  }

  displayFlash(flash) {
    const flashContainer = document.createElement('div');
    flashContainer.setAttribute('role', 'alert');
    flashContainer.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show', 'm-1');

    // Depending on the flash type, add the appropriate Bootstrap class
    for (const [type, message] of Object.entries(flash)) {
      if (type === 'notice') {
        flashContainer.classList.add('alert-info');
      } else if (type === 'alert') {
        flashContainer.classList.add('alert-warning');
      }

      console.log(message)

      flashContainer.textContent = message[1];

      const closeButton = document.createElement('button');
      closeButton.setAttribute('type', 'button');
      closeButton.classList.add('btn-close');
      closeButton.setAttribute('data-bs-dismiss', 'alert');
      closeButton.setAttribute('aria-label', 'Close');

      flashContainer.appendChild(closeButton);
    }

    document.body.appendChild(flashContainer);
  }





}
