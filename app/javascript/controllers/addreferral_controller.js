import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="addreferral"
export default class extends Controller {
  static targets = ["form", "addButton", "cancelButton", "code", "details"]

  connect() {
    if (this.element.dataset.hasReferral == "true") {
      this.showForm();
    } else {
      this.hideForm();
    }
    console.log("ADDREFERRALLLLLLLLLL_controller connected")
    console.log("code: " + this.codeTarget.value)
    console.log("details: " + this.detailsTarget.value)
  }

  addReferral() {
    document.getElementById('referral-form').style.display = 'block';
    this.showForm();
  }

  cancelReferral() {
    document.getElementById('referral-form').style.display = 'none';
    this.hideForm();
    this.codeTarget.value = "";
    this.detailsTarget.value = "";
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
