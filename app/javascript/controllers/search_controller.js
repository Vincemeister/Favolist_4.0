import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [ "form", "input", "searchresults" ]

  connect() {
    console.log("Search controller connected!!!!")
    console.log("input", this.inputTarget)
    console.log("form", this.formTarget)
  }

  update() {
    const url = `${this.formTarget.action}?query=${this.inputTarget.value}`
    console.log("url", url)
    console.log("inputvalue", this.inputTarget.value)
    fetch(url, {headers: {"Accept": "text/plain"}})
      .then(response => response.text())
      .then((data) => {

        this.searchresultsTarget.outerHTML = data
       })
      // .then((data) => {
      //   this.productsTarget.outerHTML = data
      //   this.referralsTarget.outerHTML = data
      //   this.usersTarget.outerHTML = data
      //   this.listTarget.outerHTML = data
      // })
  }
}
