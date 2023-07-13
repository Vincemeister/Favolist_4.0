import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [ "form", "products", "referrals", "lists", "users", "input" ]

  connect() {
    console.log("Search controller connected")
    console.log("input", this.inputTarget)
    console.log("inputValue", this.inputTarget.value)
    console.log("form", this.formTarget)
    console.log("products", this.productsTarget)
    console.log("referrals", this.referralsTarget)
    console.log("lists", this.listsTarget)
    console.log("users", this.usersTarget)
  }

  update() {
    const url = `${this.formTarget.action}?query=${this.inputTarget.value}`
    fetch(url, {headers: {"Accept": "json"}})
      .then(response => response.text())
      .then((data) => { console.log(data) })
      // .then((data) => {
      //   this.productsTarget.outerHTML = data
      //   this.referralsTarget.outerHTML = data
      //   this.usersTarget.outerHTML = data
      //   this.listTarget.outerHTML = data
      // })
  }
}
