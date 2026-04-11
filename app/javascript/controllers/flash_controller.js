import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._timeout = setTimeout(() => this.dismiss(), 5000)
  }

  dismiss() {
    clearTimeout(this._timeout)
    this.element.style.transition = "opacity 0.3s"
    this.element.style.opacity = "0"
    setTimeout(() => this.element.remove(), 300)
  }
}
