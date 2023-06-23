import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "link" ]
  static values = { id: Number }

  markAsRead(event) {
    event.preventDefault();
    let link = this.linkTarget.href; // Get link href to redirect after the fetch call

    fetch(`/notifications/${this.idValue}/mark_as_read`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.element.classList.remove("notification-unread");
        window.location.href = link; // Redirect
      }
    });
  }
}
