import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmarks"
export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus!")
  }

  static targets = ["bookmarkbutton"];

  toggle(event) {
    event.preventDefault();
    const url = this.bookmarkbuttonTarget.getAttribute("href");

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      credentials: "same-origin",
    })
    .then(response => {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error('Network response was not ok');
      }
    })
    .then((data) => {
      this.updateButton(data);
    })
    .catch(error => {
      console.error('There has been a problem with your fetch operation:', error);
    });
  }

  updateButton(data) {
    console.log(data)
    if (data.action === "bookmark") {
      this.bookmarkbuttonTarget.innerHTML = `
      <div class='cardbar-iconbox'>
        <i class='fa-solid fa-circle-bookmark'></i>
        <div class='iconbox-text'>${data.bookmarksCount}</div>
      </div>`;
      this.bookmarkbuttonTarget.setAttribute("href", data.unbookmark_path);
    } else if (data.action === "unbookmark") {
      this.bookmarkbuttonTarget.innerHTML = `
      <div class='cardbar-iconbox'>
        <i class='fa-light fa-circle-bookmark'></i>
        <div class='iconbox-text'>${data.bookmarksCount}</div>
      </div>`;
      this.bookmarkbuttonTarget.setAttribute("href", data.bookmark_path);
    }
  }
}
