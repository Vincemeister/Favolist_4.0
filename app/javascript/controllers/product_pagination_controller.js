import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// The HTML code for the spinner.
const spinner = `
  <div class="col-span-12 container mx-auto h-24 mb-8" id="spinner">
    <div class="loader">Loading...</div>
  </div>`;

export default class extends Controller {
  fetching = false; // debounce

  static values = {
    page: { type: Number, default: 1 },
  };

  static targets = ["products", "noRecords"];

  initialize() {
    this.scroll = this.scroll.bind(this);
  }

  connect() {
    console.log("product pagination connected");
    console.log("trying to find out:", this.productsTarget.dataset.productPaginationUrlValue);

    // Attach the scroll listener if the product tab is the default open tab
    const productTab = document.getElementById("pills-products-tab");
    if (productTab && productTab.classList.contains("active") && !this.constructor.hasProductScrollListener) {
        document.addEventListener('scroll', this.scroll);
        this.constructor.hasProductScrollListener = true;
    }
  }

  tabShown() {
    if (!this.constructor.hasProductScrollListener) {
        document.addEventListener('scroll', this.scroll);
        this.constructor.hasProductScrollListener = true;
    }
  }

  tabHidden() {
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

    console.log("Loading records...");
    console.log("urlValue:", this.productsTarget.dataset.productPaginationUrlValue);
    const url = new URL(this.productsTarget.dataset.productPaginationUrlValue);
    console.log("url:", url);
    url.searchParams.set("page", this.pageValue);
    console.log("page", this.pageValue)
    url.searchParams.set("type", "product");
    console.log("params", url.searchParams)
    console.log("url", url)

    this.fetching = true;

    await get(url.toString(), {
      responseKind: "turbo-stream",
    });
    console.log("Finished loading records...");

    this.fetching = false;
    this.pageValue += 1;
  }

  // Detect if we're at the bottom of the page.
  get #pageEnd() {
    const { scrollHeight, scrollTop, clientHeight } = document.documentElement;
    return scrollHeight - scrollTop - clientHeight < 40;
  }
}
