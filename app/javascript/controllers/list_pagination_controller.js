// lists_pagination_controller.js

import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

const spinner = `
  <div class="col-span-12 container mx-auto h-24 mb-8" id="spinner">
    <div class="loader">Loading...</div>
  </div>`;

export default class extends Controller {
  fetching = false;
  static hasListScrollListener = false; // flag for lists


  static values = {
    url: String,
    page: { type: Number, default: 1 },
    activeTab: String
  };

  static targets = ["lists", "noRecords"];

  initialize() {
    this.scroll = this.scroll.bind(this);
  }

  connect() {
    console.log("list pagination connected");
    console.log("Initial urlValue:", this.urlValue);
    console.log("Initial pageValue:", this.pageValue);
    console.log("Initial activeTabValue:", this.activeTabValue);

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
    console.log("Loading records...");

    console.log("urlValue:", this.urlValue);
    const url = new URL("http://localhost:3000/pages/search");
    console.log("url:", url);
    url.searchParams.set("page", this.pageValue);
    console.log("page", this.pageValue)
    url.searchParams.set("type", "list");
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

  get #pageEnd() {
    const { scrollHeight, scrollTop, clientHeight } = document.documentElement;
    return scrollHeight - scrollTop - clientHeight < 40;
  }
}
