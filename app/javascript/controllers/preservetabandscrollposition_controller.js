import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  saveScroll() {
    sessionStorage.setItem('scroll', window.scrollY);
  }
}
