// product_search_amazon_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "urlInput", "form" ]

  connect() {
    console.log("Hello, Stimulus!", this.element);
    console.log(this.urlInputTarget);
    console.log(this.formTarget);
    this.formTarget.addEventListener("submit", event => {
      event.preventDefault();
      this.sendRequest(this.urlInputTarget.value);
    });
  }

  sendRequest(asin) {
    fetch(`https://parazun-amazon-data.p.rapidapi.com/product/?asin=${asin}&region=US`, {
      headers: {
        "Accept": "application/json",
        "X-RapidAPI-Key": "971b32dc4emshdc908738f2fb7c0p15bcc5jsn4f8c98db4f7d",
        "X-RapidAPI-Host": "parazun-amazon-data.p.rapidapi.com"
      }
    })
    .then(response => response.json())
    .then((data) => {
      console.log(data)
    });
      }

}
