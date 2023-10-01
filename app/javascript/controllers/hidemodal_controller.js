import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidemodal"
// this is to counter a misfunction of where when I open a modal (either to create a new product or list, or editing a product,
// and then return back to the initial page the modal is still open without the ability to close it because the state is cached and for some reason the close button is not working)
// this controller is to close all modals when a new page is loaded
export default class extends Controller {
  connect() {
    this.closeModalWhenDetected();
  }

  closeModalWhenDetected() {
    const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        if (mutation.addedNodes.length) {
          this.closeModals();
        }
      });
    });

    observer.observe(document.body, { childList: true, subtree: true });
  }

  closeModals() {
    // Close all modals
    document.querySelectorAll('.modal.show').forEach(modal => {
      modal.classList.remove('show');
      modal.setAttribute('aria-hidden', 'true');
      modal.style.display = 'none';
    });

    // Remove the modal backdrop
    document.querySelectorAll('.modal-backdrop').forEach(backdrop => {
      backdrop.remove();
    });

    // Ensure the body is scrollable and remove modal-related classes and styles
    document.body.classList.remove('modal-open');
    document.body.style.overflow = '';
  }
}
