import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["commentform", "comments"]

  connect() {
  }

  submit(event) {
    event.preventDefault();

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
      console.log("Data received from server:", data);
      if (data.error) {
        console.log("Error from server:", data.error);
        // Handle error...
      } else if (data.inserted_item) {
        this.commentsTarget.insertAdjacentHTML("beforeend", data.inserted_item)
      }
      this.commentformTarget.outerHTML = data.form // Make sure this target is correctly defined
    })
    this.displayFlashMessage("success", "Reply created successfully");

    this.scrollToBottom();




  }

  scrollToBottom() {
    const commentsContainer = this.commentsTarget;
    const scrollPosition = commentsContainer.lastElementChild.offsetTop;
    window.scrollTo({ top: scrollPosition, behavior: 'smooth' });
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
