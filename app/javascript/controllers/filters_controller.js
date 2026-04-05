import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "icon"]

  toggle() {
    const hidden = this.panelTarget.classList.contains("hidden")
    this.panelTarget.classList.toggle("hidden", !hidden)
    this.iconTarget.classList.toggle("text-cuhk-gold", hidden)
    this.iconTarget.classList.toggle("text-white/60", !hidden)
  }
}
