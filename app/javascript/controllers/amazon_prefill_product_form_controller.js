// product_prefill_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "title", "price", "description" ]

  connect() {
    const fetchedProduct = JSON.parse(localStorage.getItem('fetchedProduct'));
    if (fetchedProduct) {
      this.titleTarget.value = fetchedProduct.title;
      this.priceTarget.value = fetchedProduct.price;
      this.descriptionTarget.value = fetchedProduct.description;
      localStorage.removeItem('fetchedProduct');
    }
  }
}
