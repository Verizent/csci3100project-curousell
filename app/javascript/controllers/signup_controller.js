import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="signup"
export default class extends Controller {
  static targets = ["termsCheckbox", "submitBtn", "modal"]

  connect() {
    this.submitBtnTarget.disabled = true
  }

  toggleSubmit() {
    this.submitBtnTarget.disabled = !this.termsCheckboxTarget.checked
  }

  openModal() {
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  closeModal() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
