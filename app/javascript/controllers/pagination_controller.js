import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// The HTML code for the spinner.
const spinner = `
  <div class="col-span-12 container mx-auto h-24 mb-8" id="spinner">
    <div class="loader">Loading...</div>
  </div>`;

export default class extends Controller {
  fetching = false; // debounce
  hasProductScrollListener = false;  // Add this line to initialize a flag


  static values = {
    url: String,
    page: { type: Number, default: 1 },
  };

  static targets = ["products", "noRecords"];

  initialize() {
    this.scroll = this.scroll.bind(this);
  }

  connect() {
    if (!this.constructor.hasProductScrollListener) {
      document.addEventListener('scroll', this.scroll);
      this.constructor.hasProductScrollListener = true;
    this.#loadRecords();
  }
  }


  disconnect() {
    if (this.constructor.hasProductScrollListener) {
        document.removeEventListener('scroll', this.scroll);
        this.constructor.hasProductScrollListener = false;
    }
}

  scroll() {
    if (this.#pageEnd && !this.fetching && !this.hasNoRecordsTarget) {
      // Add the spinner at the end of the page.
      this.productsTarget.insertAdjacentHTML("beforeend", spinner);

      this.#loadRecords();
    }
  }

  // Send a turbo-stream request to the controller.
  async #loadRecords() {
    const url = new URL(this.urlValue);
    url.searchParams.set("page", this.pageValue);

    this.fetching = true;

    await get(url.toString(), {
      responseKind: "turbo-stream",
    });

    this.fetching = false;
    this.pageValue += 1;
  }

  // Detect if we're at the bottom of the page.
  get #pageEnd() {
    const { scrollHeight, scrollTop, clientHeight } = document.documentElement;
    return scrollHeight - scrollTop - clientHeight < 40;
  }
}
