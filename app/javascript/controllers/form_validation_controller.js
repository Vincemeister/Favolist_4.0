import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-validation"
export default class extends Controller {

  static targets = ["title", "price", "listId", "description", "review", "url", "logoBlob", "photosBlobs", "titleError", "priceError", "descriptionError", "reviewError", "urlError", "logoError", "photosError"]

  connect() {
    console.log("Form validation controller connected")
    console.log("photos: ", this.photosTarget)
    console.log("Logo Error Target: ", this.logoErrorTarget);
    console.log("Photos Error Target: ", this.photosErrorTarget);
  }

  submit(event) {
    if (!this.validateForm()) {
      event.preventDefault()  // Stop form from submitting
    }
  }

  submit(event) {
    console.log('Submit function called');
    if (!this.validateForm()) {
      console.log('Form is invalid. Preventing form submission.');
      event.preventDefault()  // Stop form from submitting
    } else {
      console.log('Form is valid. Proceeding with form submission.');
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

    // Check if price is not empty
    if (this.priceTarget.value === "") {
      isValid = false
      this.priceErrorTarget.textContent = 'Price cannot be empty'
      this.priceTarget.scrollIntoView({behavior: "smooth"})
    } else {
      this.priceErrorTarget.textContent = ''
    }

    // Check if description is not empty
    if (this.descriptionTarget.value === "") {
      isValid = false
      this.descriptionErrorTarget.textContent = 'Description cannot be empty'
      this.descriptionTarget.scrollIntoView({behavior: "smooth"})
    } else {
      this.descriptionErrorTarget.textContent = ''
    }

    // Check if review is not empty
    if (this.reviewTarget.value === "") {
      isValid = false
      this.reviewErrorTarget.textContent = 'Review cannot be empty'
      this.reviewTarget.scrollIntoView({behavior: "smooth"})
    } else {
      this.reviewErrorTarget.textContent = ''
    }

    // Check if url is not empty
    if (this.urlTarget.value === "") {
      isValid = false
      this.urlErrorTarget.textContent = 'URL cannot be empty'
      this.urlTarget.scrollIntoView({behavior: "smooth"})
    } else {
      this.urlErrorTarget.textContent = ''
    }

  // Check if logo is not empty
  if (this.logoBlobTarget.value === "") {
    isValid = false
    this.logoErrorTarget.textContent = 'Logo cannot be empty'
    this.logoBlobTarget.scrollIntoView({behavior: "smooth"})
    console.log('Logo validation failed.');
  } else {
    this.logoErrorTarget.textContent = ''
  }

  // Check if photos are not empty
  if (this.photosBlobsTarget.value === "") {
    isValid = false
    this.photosErrorTarget.textContent = 'Photos cannot be empty'
    this.photosBlobsTarget.scrollIntoView({behavior: "smooth"})
    console.log('Photos validation failed.');
  } else {
    this.photosErrorTarget.textContent = ''
  }


    return isValid
  }

}
