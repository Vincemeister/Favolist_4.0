import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"
import Dropzone from "dropzone"
import { getMetaValue, findElement, removeElement, insertAfter } from "../helpers/dropzone"

Dropzone.autoDiscover = false

export default class extends Controller {
  static targets = [ "input" ]
  static values = [ "logo-for-edit", "photos-for-edit"]

  connect() {
    console.log("Dropzone: ", this)
    console.log("Classlist: ", this.element.classList)
    this.dropZone = createDropZone(this)
    this.hideFileInput()
    this.bindEvents()
    this.populateWithExistingLogo() // Call the new function here
    this.populateWithExistingImages() // Call the new function here
    console.log("Dropzone connected")
  }


  populateWithExistingLogo() {
    console.log('populateWithExistingLogo called')

    let logoData = this.data.get("logo")
    if (logoData) {
      let logo = JSON.parse(logoData)
      console.log('Parsed logo:', logo)

      console.log('Processing logo:', logo)

      let mockFile = {
        name: "Filename",
        size: 12345,
        status: Dropzone.ADDED,
        accepted: true,
        url: logo.url,
        copiedProduct: true
      }

      // Check if blob_signed_id exists in the logo hash
      if (logo.blob_signed_id) {
        mockFile.blobSignedId = logo.blob_signed_id

        // Create a hidden input for each mock file, similar to what's done in DirectUploadController
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "product[logo]"
        input.value = logo.blob_signed_id
        this.element.appendChild(input)
      }

      this.dropZone.emit("addedfile", mockFile)
      this.dropZone.emit("thumbnail", mockFile, logo.url)
      this.dropZone.emit("complete", mockFile) // Mark the file as uploaded
      mockFile.status = Dropzone.SUCCESS // Indicate that the file is already uploaded
    }
  }


  populateWithExistingImages() {
    console.log('populateWithExistingImages called')

    let photosData = this.data.get("photos")
    if (photosData) {
        let photos = JSON.parse(photosData)
        console.log('Parsed photos:', photos)

        photos.forEach(photo => {
          console.log('Processing photo:', photo)

            let mockFile = { name: "Filename", size: 12345, status: Dropzone.ADDED, accepted: true, url: photo.url, copiedProduct: true, blobSignedId: photo.blob_signed_id }

            this.dropZone.emit("addedfile", mockFile)
            this.dropZone.emit("thumbnail", mockFile, photo.url)
            this.dropZone.emit("complete", mockFile) // Mark the file as uploaded
            mockFile.status = Dropzone.SUCCESS // Indicate that the file is already uploaded

            // Create a hidden input for each mock file, similar to what's done in DirectUploadController
            const input = document.createElement("input")
            input.type = "hidden"
            input.name = "product[photos][]"
            input.value = photo.blob_signed_id
            this.element.appendChild(input)
        })
    }
  }



// Private
  hideFileInput() {
    this.inputTarget.disabled = true
    this.inputTarget.style.display = "none"
  }

  bindEvents() {
    this.dropZone.on("addedfile", (file) => {
      console.log('addedfile event triggered with file:', file)

      if (this.element.classList.contains("dropzone-logo")) {
        document.getElementById('logoBlob').value = file.name;
      } else {
        let photosBlobs = document.getElementById('photosBlobs').value;
        photosBlobs = photosBlobs ? photosBlobs.split(',') : [];
        photosBlobs.push(file.name);
        document.getElementById('photosBlobs').value = photosBlobs.join(',');
      }


      // -----------------FOR THE EDIT FORM-----------------------------------------------------------------------------------
      const logoDataElement = this.logoForEditValue;
      const photosDataElement = this.photosForEditValue;

      if (logoDataElement) {
          // Parse logo data
          let logoData = JSON.parse(logoDataElement.getAttribute.this.logoForEditValue);

          // Create a mock file with server-side data
          let mockFile = { name: logoData.name, size: logoData.size, type: logoData.type };

          // Call the default addedfile event handler
          this.emit("addedfile", mockFile);

          // And optionally show the thumbnail of the file
          this.emit("thumbnail", mockFile, logoData.url);

          // If you use the maxFiles option, make sure to adjust it as well
          this.options.maxFiles = this.options.maxFiles - 1;
      }

      if (photosDataElement) {
          // Parse photos data
          let photosData = JSON.parse(photosDataElement.getAttribute(getAttribute.this.logoForEditValue));

          // Handle each photo
          photosData.forEach(photoData => {
              // Create a mock file with server-side data
              let mockFile = { name: photoData.name, size: photoData.size, type: photoData.type };

              // Call the default addedfile event handler
              this.emit("addedfile", mockFile);

              // And optionally show the thumbnail of the file
              this.emit("thumbnail", mockFile, photoData.url);

              // If you use the maxFiles option, make sure to adjust it as well
              this.options.maxFiles = this.options.maxFiles - 1;
          });
      }
// ---------------------------------------------------------------------------------------------------------------------





      setTimeout(() => { file.accepted && createDirectUploadController(this, file).start() }, 500)
    })


    this.dropZone.on("thumbnail", (file, dataUrl) => {
      if (file.copiedProduct) {
        // Locate the img element within the preview template
        let imgElement = file.previewElement.querySelector("[data-dz-thumbnail]");

        // Add your styles here
        imgElement.style.objectFit = "contain";
        imgElement.style.width = "100%";
        imgElement.style.height = "100%";
      }
    })




    this.dropZone.on("removedfile", (file) => {
      console.log('removedfile event triggered with file:', file)

      if (this.element.classList.contains("dropzone-logo")) {
        // if the removed file is a logo, just clear the input field
        document.getElementById('logoBlob').value = "";
      } else {
        let photosBlobs = document.getElementById('photosBlobs').value;
        photosBlobs = photosBlobs ? photosBlobs.split(',') : [];
        photosBlobs = photosBlobs.filter(blob => blob !== file.name); // remove the file from the list
        document.getElementById('photosBlobs').value = photosBlobs.join(',');
      }

      if (file.blobSignedId) {
        // This is an Active Storage object. Remove it in the usual way.
        let hiddenInput = this.element.querySelector(`input[type="hidden"][value="${file.blobSignedId}"]`)
        hiddenInput && hiddenInput.remove()
      } else if (file.url) {
        // This is an Amazon logo. Do whatever you need to do here.
        // If you're adding the Amazon logo URL to a hidden input field, you would remove that field here.
        // REDUNDANT SINCE I CREATED AND AMAZON LOGO BLOB IN THE SEED?
      }

      file.controller && removeElement(file.controller.hiddenInput)
      console.log('Hidden inputs after removal:', this.element.querySelectorAll('input[type="hidden"]'))
    })



    this.dropZone.on("canceled", (file) => {
      file.controller && file.controller.xhr.abort()
    })

    this.dropZone.on("processing", (file) => {
      this.submitButton.disabled = true
      console.log(`Processing file: ${file.name}`);

    })

    this.dropZone.on("queuecomplete", (file) => {
      this.submitButton.disabled = false
      console.log("All files have been uploaded.");

    })

    this.dropZone.on("error", (file, error) => {
      console.log(`Error uploading file: ${file.name} - ${error}`);
    })

  }

  get headers() { return { "X-CSRF-Token": getMetaValue("csrf-token") } }

  get url() { return this.inputTarget.getAttribute("data-direct-upload-url") }

  get maxFiles() { return this.data.get("maxFiles") || 1 }

  get maxFileSize() { return this.data.get("maxFileSize") || 256 }

  get acceptedFiles() { return this.data.get("acceptedFiles") }

  get addRemoveLinks() { return this.data.get("addRemoveLinks") || true }

  get form() { return this.element.closest("form") }

  get submitButton() { return findElement(this.form, "input[type=submit], button[type=submit]") }

}

class DirectUploadController {
  constructor(source, file) {
    this.directUpload = createDirectUpload(file, source.url, this)
    this.source = source
    this.file = file
  }

  start() {

    this.file.controller = this
    this.hiddenInput = this.createHiddenInput()

    console.log(this);
    this.directUpload.create((error, attributes) => {
      if (error) {
        removeElement(this.hiddenInput)
        this.emitDropzoneError(error)
      } else {
        this.hiddenInput.value = attributes.signed_id
        this.emitDropzoneSuccess()
      }
    })
  }

// Private
  createHiddenInput() {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = this.source.inputTarget.name

    insertAfter(input, this.source.inputTarget)
    console.log('Created hidden input with value:', input.value)
    return input
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr)
    this.emitDropzoneUploading()
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr
    this.xhr.upload.addEventListener("progress", event => this.uploadRequestDidProgress(event))
  }

  uploadRequestDidProgress(event) {
    const element = this.source.element
    const progress = event.loaded / event.total * 100
    findElement(this.file.previewTemplate, ".dz-upload").style.width = `${progress}%`
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING
    this.source.dropZone.emit("processing", this.file)
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR
    console.log(`Error uploading file: ${this.file.name} - ${error}`)

    this.source.dropZone.emit("error", this.file, error)
    this.source.dropZone.emit("complete", this.file)
  }

  emitDropzoneSuccess() {

    this.file.status = Dropzone.SUCCESS
    console.log(`File uploaded successfully: ${this.file.name}`)
    this.source.dropZone.emit("success", this.file)
    this.source.dropZone.emit("complete", this.file)
  }
}

// -----------------------------------------------------------------------------

// Top level...
function createDirectUploadController(source, file) {
  return new DirectUploadController(source, file)
}

function createDirectUpload(file, url, controller) {
  return new DirectUpload(file, url, controller)
}

function createDropZone(controller) {
  return new Dropzone(controller.element, {
    url: controller.url,
    headers: controller.headers,
    maxFiles: controller.maxFiles,
    maxFilesize: controller.maxFileSize,
    acceptedFiles: controller.acceptedFiles,
    addRemoveLinks: controller.addRemoveLinks,
    autoQueue: false
  })
}
