// product_search_amazon_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "urlInput" ]

  connect() {
    console.log("Hello, Stimulus!", this.element);
    this.urlInputTarget.addEventListener("submit", event => {
      event.preventDefault();

      const url = this.urlInputTarget.value;
      const request = new Request("/products/fetch_amazon", {
        method: "POST",
        body: JSON.stringify({ url: url }),
        headers: {
          "X-CSRF-Token": getMetaValue("csrf-token"),
          "Content-Type": "application/json"
        },
        credentials: "same-origin"
      });

      fetch(request)
        .then(response => response.json())
        .then(data => {
          localStorage.setItem('fetchedProduct', JSON.stringify(data));
          window.location.href = '/products/new';
        });
    });
  }
}

function getMetaValue(name) {
  const element = document.head.querySelector(`meta[name="${name}"]`);
  return element.getAttribute("content");
}
