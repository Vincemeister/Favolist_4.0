import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["commentform", "comments"]


  connect() {
    console.log("Comments controller connected")
  }



  submitForm(event) {
    event.preventDefault()

    fetch(this.commentformTarget.action, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
       },
      body: new FormData(this.commentformTarget)
    })
    .then(response => response.json())
    .then((data) => {
      if (data.inserted_item) {
        this.commentsTarget.insertAdjacentHTML("beforeend", data.inserted_item)
      }
      this.commentformTarget.outerHTML = data.form
    })
    this.displayFlashMessage("success", "Comment/Reply created successfully");
  }


  displayFlashMessage(type, message) {
    const flashElement = document.createElement("div");
    flashElement.className = `alert alert-${type} flash`;
    flashElement.innerText = message;
    document.body.appendChild(flashElement);

    setTimeout(() => {
      flashElement.remove();
    }, 3000);
  }

}
