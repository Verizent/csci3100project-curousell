import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form"]
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this._timeout = null
  }

  search() {
    clearTimeout(this._timeout)
    this._timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, this.delayValue)
  }
}
