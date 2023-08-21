import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="avatar-preview"
export default class extends Controller {
  connect() {
  }

  static targets = ["input"]

  preview() {
    let input = this.inputTarget;
    let preview = document.getElementById('img-preview');
    if (input.files && input.files[0]) {
      let reader = new FileReader();
      reader.onload = (e) => {
        preview.src = e.target.result;
      }
      reader.readAsDataURL(input.files[0]);
    }
  }
}
