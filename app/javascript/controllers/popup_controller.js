import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="popup"
export default class extends Controller {
  static targets = ["banner"]

  connect() {
    // Check if the banner was shown today
    const lastShown = localStorage.getItem('popupLastShown');
    const today = new Date().toDateString();

    if (lastShown !== today) {
      setTimeout(() => {
        this.bannerTarget.style.display = 'block'
      }, 60000); // 60 seconds
    }
  }

  close() {
    this.bannerTarget.style.display = 'none';
    // Save the current date as the last time the popup was shown
    const today = new Date().toDateString();
    localStorage.setItem('popupLastShown', today);
  }
}
