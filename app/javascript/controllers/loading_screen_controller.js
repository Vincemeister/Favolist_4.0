import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading-screen"
export default class extends Controller {
  static targets = ["fact", "searchform"];

  connect() {
    console.log ("Loading screen controller connected...")
    console.log ("Fact targets:", this.factTargets);
    console.log ("Search form:", this.searchformTarget);
    console.log ("Element:", this.element);
    console.log ("loadingScreen:",  document.getElementById('loadingScreen'));

  }

  show() {
    console.log("Showing loading screen...");
    document.getElementById('loadingScreen').style.display = 'block';
    this.searchformTarget.style.display = 'none';
    this.fetchFacts();
  }

  hide() {
    document.getElementById('loadingScreen').style.display = 'none';
  }

  fetchFacts() {
    console.log("Fetching facts...");
    // Perform the AJAX request to fetch facts
    fetch('/fetch_facts')
      .then(response => response.json())
      .then(data => {
        console.log("Facts fetched:", data);
        // Update the displayed facts
        this.factTargets.forEach((element, index) => {
          if (data[index]) {
            // Create a span element for the fact number
            const factNumber = document.createElement('span');
            factNumber.className = 'fact-number';
            factNumber.textContent = `Fact #${index + 1}: `;

            // Clear existing content
            element.textContent = '';

            // Append the fact number and the fact text
            element.appendChild(factNumber);
            element.append(data[index].fact);
          }
        });
      })
      .catch(error => console.error("Error fetching facts:", error));
  }



  scrape(event) {
    console.log("Scraping triggered");

    // event.preventDefault();
    this.show();

    // let form = event.target;
    // fetch(form.action, {
    //     method: form.method,
    //     body: new FormData(form),
    //     headers: {
    //         'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    //     }
    // }).then(response => {
    //     console.log("Response received:", response);

    //     if (response.redirected) {
    //         console.log("Redirecting to:", response.url);
    //         Turbolinks.visit(response.url); // Use Turbolinks for redirection
    //     } else {
    //         console.log("Handling non-redirect response");
    //         // TODO: Handle error or non-success case
    //     }

    //     this.hide();
    // }).catch(error => {
    //     console.error('Scraping failed:', error);
    //     this.hide();
    //     // TODO: Handle error presentation to the user
    // });
}

disconnect() {
    console.log("Loading screen controller disconnected...");
}

}
