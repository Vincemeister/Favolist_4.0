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
    rows.forEach((images, index) => {
      const row = this.rowTargets[index]
      if (!row) return;

      const imageElements = images.map(imageUrl => `<img class="uniform" style="width: ${100/images.length}%" src="${imageUrl}" />`).join('')

      row.innerHTML = `<div class="sliding-row-content">${imageElements + imageElements}</div>`
    })
  }
}
