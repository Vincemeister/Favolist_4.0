import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="addreferral"
export default class extends Controller {
  static targets = ["form", "addButton", "cancelButton"]

  connect() {
    if (this.element.dataset.hasReferral == "true") {
      this.showForm();
    } else {
      this.hideForm();
    }
  }

  addReferral() {
    this.showForm();
  }

  cancelReferral() {
    this.hideForm();
  }

  showForm() {
    this.formTarget.style.display = 'block';
    this.addButtonTarget.style.display = 'none';
    this.cancelButtonTarget.style.display = 'block';
  }

  hideForm() {
    this.formTarget.style.display = 'none';
    this.addButtonTarget.style.display = 'block';
    this.cancelButtonTarget.style.display = 'none';
  }
}
