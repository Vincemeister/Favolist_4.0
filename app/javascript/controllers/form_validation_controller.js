import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-validation"
export default class extends Controller {


  static targets = [ "title", "price", "listId", "description", "review", "url", "titleError" ]
  connect() {
    console.log ("Form validation controller connected")
    console.log ("this.titleTarget:", this.titleTarget)
  }

  submit(event) {
    if (!this.validateForm()) {
      event.preventDefault()  // Stop form from submitting
    }
  }

  validateForm() {
    let isValid = true

    // Check if title is not empty
    if (this.titleTarget.value === "") {
      isValid = false
      this.titleErrorTarget.textContent = 'Title cannot be empty'
      this.titleTarget.scrollIntoView({behavior: "smooth"})
    } else {
      this.titleErrorTarget.textContent = '' // Clear any previous error message
    }

    // Repeat similar checks for other fields...

    return isValid
  }

}
