import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// The HTML code for the spinner.
const spinner = `
  <div class="col-span-12 container mx-auto h-24 mb-8" id="spinner">
    <div class="loader">Loading...</div>
  </div>`;

export default class extends Controller {
  fetching = false; // debounce

  hasListScrollListener = false;
  hasLoadedInitialRecords = false;

  static values = {
    page: { type: Number, default: 1 },
  };

  static targets = ["referrals", "noRecords"];

  initialize() {
    this.scroll = this.scroll.bind(this);
  }

  connect() {
    console.log("referral pagination connected");
    console.log("trying to find out:", this.referralsTarget.dataset.referralPaginationUrlValue);
  }
  
  tabShown() {
    if (!this.hasListScrollListener) {
        document.addEventListener('scroll', this.scroll);
        this.hasListScrollListener = true;
    }
    if (!this.hasLoadedInitialRecords) {
        this.#loadRecords();
        this.hasLoadedInitialRecords = true;
    }
 }


 tabHidden() {
  if (this.hasListScrollListener) {
      document.removeEventListener('scroll', this.scroll);
      this.hasListScrollListener = false;
  }
}


  scroll() {
    if (this.#pageEnd && !this.fetching && !this.hasNoRecordsTarget) {
      // Add the spinner at the end of the page.
      this.referralsTarget.insertAdjacentHTML("beforeend", spinner);

      this.#loadRecords();
    }
  }

  // Send a turbo-stream request to the controller.
  async #loadRecords() {

    console.log("Loading records...");
    console.log("urlValue:", this.referralsTarget.dataset.referralPaginationUrlValue);
    const url = new URL(this.referralsTarget.dataset.referralPaginationUrlValue);
    console.log("url:", url);
    url.searchParams.set("page", this.pageValue);
    console.log("page", this.pageValue)
    url.searchParams.set("type", "referral");
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
