import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slidingimagerows"
export default class extends Controller {
  static targets = ['row']

  connect() {
    console.log('Hello from slidingimagerows_controller.js')
    this.loadImages()
  }

  loadImages() {
    fetch('/products/photos')
      .then(response => response.json())
      .then(data => this.handleImages(data))
      .catch(error => console.error('Error:', error));
  }

  handleImages(rows) {
    // Your code here to populate the sliding image rows
    rows.forEach((images, index) => {
      // Grab the corresponding row
      const row = this.rowTargets[index]

      // If row does not exist, return and continue with next iteration
      if (!row) return;

      // Add a 'uniform' class to the image element
      const imageElements = images.map(imageUrl => `<img class="uniform" src="${imageUrl}" />`).join('')
      row.innerHTML = imageElements
    })
  }


}
