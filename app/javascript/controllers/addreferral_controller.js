import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="addreferral"
export default class extends Controller {
  static targets = ["form", "addButton", "cancelButton"]

  connect() {
    this.hideForm()
    console.log("Hello from addreferral_controller.js")
  }

  addReferral() {
    this.formTarget.style.display = 'block';
    this.addButtonTarget.style.display = 'none';
    this.cancelButtonTarget.style.display = 'block';
  }

  cancelReferral() {
    this.hideForm()
  }

  hideForm() {
    this.formTarget.style.display = 'none';
    this.addButtonTarget.style.display = 'block';
    this.cancelButtonTarget.style.display = 'none';
  }
}
