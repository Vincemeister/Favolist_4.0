import { Controller } from "@hotwired/stimulus"



export default class extends Controller {

  static targets = [ "replyform", "commentlastreplies" ]

  connect() {
    console.log("Replies and Comments controller connected")
  }

  togglereplyform() {
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
        console.log("Data received from server:", data);

        if (data.error) {
          console.log("Error from server:", data.error);
          // Handle error...
        } else if (data.inserted_item) {
          console.log("Inserting item into the DOM.");
          this.commentlastrepliesTarget.insertAdjacentHTML("beforeend", data.inserted_item)
          console.log("this is the inserted item", data.inserted_item);
        }

        console.log("Updating reply form.");
        console.log("this is the form", data.form)
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
