import { Controller } from "@hotwired/stimulus"



// Connects to data-controller="replies"
export default class extends Controller {

  static targets = [ "replies", "viewrepliesbutton", "replyform" ]

  toggleReplies() {
      this.repliesTarget.classList.toggle("d-none");
      this.viewrepliesbuttonTarget.innerHTML =
        this.repliesTarget.classList.contains("d-none")
          ? `View all  replies`
          : `Hide all  replies`;
    }

  toggleReplyForm() {
    this.replyformTarget.classList.toggle("d-none");
  }

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
      }
      this.replyformTarget.outerHTML = data.form
    })
    this.toggleReplyForm
  }

  }
