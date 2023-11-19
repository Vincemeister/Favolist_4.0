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
  hasLoadedInitialRecords = false;


  static values = {
    page: { type: Number, default: 1 },
  };

  static targets = ["products", "noRecords"];

  initialize() {
    this.scroll = this.scroll.bind(this);
  }

  connect() {
    console.log("product pagination connected");
  }


  disconnect() {
    if (this.hasProductScrollListener) {
        document.removeEventListener('scroll', this.scroll);
        this.hasProductScrollListener = false;
    }
}



  tabShown() {
    if (!this.hasProductScrollListener) {
        document.addEventListener('scroll', this.scroll);
        this.hasProductScrollListener = true;
    }
    if (!this.hasLoadedInitialRecords) {
        this.#loadRecords();
        this.hasLoadedInitialRecords = true;
    }
  }


  tabHidden() {
    if (this.hasProductScrollListener) {
        document.removeEventListener('scroll', this.scroll);
        this.hasProductScrollListener = false;
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

    console.log("Loading product records...");
    console.log("product urlValue:",  this.productsTarget.dataset.productPaginationUrlValue);
    const url = new URL(this.productsTarget.dataset.productPaginationUrlValue);
    console.log("product url:", url);
    url.searchParams.set("page", this.pageValue);
    console.log("product page", this.pageValue)
    url.searchParams.set("type", "product");
    console.log("porduct params", url.searchParams)
    console.log("product url with params", url)

    this.fetching = true;


    try {
      await get(url.toString(), {
        responseKind: "turbo-stream",
      });
      console.log("Finished product loading records...");
    } catch (error) {
      console.error("Error loading records:", error);
    } finally {
      this.removeSpinner();
      this.fetching = false;
      this.pageValue += 1;
    }
  }

  // Detect if we're at the bottom of the page.
  get #pageEnd() {
    const { scrollHeight, scrollTop, clientHeight } = document.documentElement;
    return scrollHeight - scrollTop - clientHeight < 3000;
  }

  removeSpinner() {
    const spinnerElement = this.productsTarget.querySelector("#spinner");
    if (spinnerElement) {
      spinnerElement.remove();
    }
  }
}
