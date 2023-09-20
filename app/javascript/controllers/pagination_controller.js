import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// The HTML code for the spinner.
const spinner = `
  <div class="col-span-12 container mx-auto h-24 mb-8" id="spinner">
    <div class="loader">Loading...</div>
  </div>`;

export default class extends Controller {
  fetching = false; // debounce
  static hasProductScrollListener = true;  // Add this line to initialize a flag


  static values = {
    url: String,
    page: { type: Number, default: 1 },
  };

  static targets = ["products", "noRecords"];

  initialize() {
    this.scroll = this.scroll.bind(this);
  }

  connect() {
    console.log("product pagination connected");
    console.log("Initial urlValue:", this.urlValue);
    console.log("Initial pageValue:", this.pageValue);

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

    console.log("urlValue:", this.urlValue);
    const url = new URL("http://localhost:3000/pages/search");
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
