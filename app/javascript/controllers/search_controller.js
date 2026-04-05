import { Controller } from "@hotwired/stimulus"

// Persists across frame swaps — survives element replacement
let shouldRefocus = false
let savedCursor   = 0

export default class extends Controller {
  static targets = ["input", "form"]
  static values  = { delay: { type: Number, default: 850 } }

  connect() {
    this._timeout = null
    if (shouldRefocus) {
      shouldRefocus = false
      this.inputTarget.focus()
      this.inputTarget.setSelectionRange(savedCursor, savedCursor)
    }
  }

  disconnect() {
    clearTimeout(this._timeout)
  }

  search() {
    if (document.activeElement === this.inputTarget) {
      shouldRefocus = true
      savedCursor   = this.inputTarget.selectionStart
    }
    clearTimeout(this._timeout)
    this._timeout = setTimeout(() => this.formTarget.requestSubmit(), this.delayValue)
  }
}
