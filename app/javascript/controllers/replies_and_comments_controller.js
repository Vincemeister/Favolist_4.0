import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-and-replies"
export default class extends Controller {
  connect() {
    console.log("hello from comment-and-replies controller")
  };

  static targets = ["replyform", "replies", "viewrepliesbutton", "firstreply"]
  static values = { repliescount: String, commentid: String }

  toggleReplies(event) {
    console.log(this.commentidValue)
    event.preventDefault();
    this.repliesTarget.classList.toggle("d-none");
    this.firstreplyTarget.classList.toggle("d-none");
    this.viewrepliesbuttonTarget.innerHTML =
      this.repliesTarget.classList.contains("d-none")
        ? `View all ${this.repliescountValue} replies`
        : `Hide all ${this.repliescountValue} replies`;
  }

  toggleReplyForm(event) {
    event.preventDefault();
    this.replyformTarget.classList.toggle("d-none");
  };

  submitReply(event) {
    event.preventDefault();

    fetch(this.replyformTarget.action, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
      },
      body: new FormData(this.replyformTarget)
    })
    .then(response => response.json())
    .then((data) => {
      if (data.inserted_item) {
        this.repliesTarget.insertAdjacentHTML("beforeend", data.inserted_item)
        this.firstreplyTarget.insertAdjacentHTML("beforeend", data.inserted_item)
      }
      this.replyformTarget.outerHTML = data.form
    })
    this.toggleReplyForm
    this.displayFlashMessage("success", "Reply created successfully");
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
