// lists_pagination_controller.js

import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

const spinner = `
  <div class="col-span-12 container mx-auto h-24 mb-8" id="spinner">
    <div class="loader">Loading...</div>
  </div>`;

export default class extends Controller {
  fetching = false;
// Add these at the beginning of the class
  hasListScrollListener = false;



  static values = {
    page: { type: Number, default: 1 },
    url: String
  };

  static targets = ["lists", "noRecords"];

  initialize() {
    this.scroll = this.scroll.bind(this);
  }


  connect() {
    console.log("product pagination connected");
    console.log("productPagination initial url value:", this.listsTarget.dataset.listPaginationUrlValue);
    console.log("list URL VALUE:", this.listsTarget.dataset.listPaginationUrlValue);

    // Attach the scroll listener if the product tab is the default open tab
    const listTab = document.getElementById("pills-lists-tab");
    if (listTab && listTab.classList.contains("active") && !this.constructor.hasListScrollListener) {
        document.addEventListener('scroll', this.scroll);
        this.constructor.hasListScrollListener = true;
      this.#loadRecords();
    }
  }

  disconnect() {
    if (this.constructor.hasListScrollListener) {
        document.removeEventListener('scroll', this.scroll);
        this.constructor.hasListScrollListener = false;
    }
}





 tabShown() {
  if (!this.constructor.hasListScrollListener) {
      document.addEventListener('scroll', this.scroll);
      this.constructor.hasListScrollListener = true;
  }
}





tabHidden() {
  if (this.constructor.hasListScrollListener) {
      document.removeEventListener('scroll', this.scroll);
      this.constructor.hasListScrollListener = false;
  }
}




  scroll() {
    if (this.#pageEnd && !this.fetching && !this.hasNoRecordsTarget) {
      this.listsTarget.insertAdjacentHTML("beforeend", spinner);
      this.#loadRecords();
    }
  }




  async #loadRecords() {
    console.log("Loading list records...");

    console.log("list urlValue:", this.listsTarget.dataset.listPaginationUrlValue);
    const url = new URL(this.listsTarget.dataset.listPaginationUrlValue);
    console.log("list url:", url);
    url.searchParams.set("page", this.pageValue);
    console.log("list page", this.pageValue)
    url.searchParams.set("type", "list");
    console.log("list params", url.searchParams)
    console.log("list url with params", url)


    this.fetching = true;

    await get(url.toString(), {
      responseKind: "turbo-stream",
    });
    console.log("Finished loading list records...");


    this.fetching = false;
    this.pageValue += 1;
  }

  get #pageEnd() {
    const { scrollHeight, scrollTop, clientHeight } = document.documentElement;
    return scrollHeight - scrollTop - clientHeight < 40;
  }
}
