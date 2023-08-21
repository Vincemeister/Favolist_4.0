import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="charactercounter"
export default class extends Controller {
  static targets = ["counter"]
  static values = { limit: Number } // Add this


  connect() {
    console.log("CHARACTER COUNTER YO", this.element)
    console.log(this.counterTarget)
    console.log(this.limitValue);

  }


  updateCounter(event) {
    const numberOfCharacters = event.currentTarget.value.length;

    if (numberOfCharacters === 0) {
        this.counterTarget.innerHTML = "";
    } else if (numberOfCharacters <= this.limitValue) {
        this.counterTarget.innerHTML = `${numberOfCharacters}/${this.limitValue}`;
    } else {
        this.counterTarget.innerHTML = `${numberOfCharacters}/${this.limitValue} - Exceeded by ${numberOfCharacters - this.limitValue}`;
    }
  }

}
