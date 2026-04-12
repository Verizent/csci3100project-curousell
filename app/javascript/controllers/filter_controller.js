import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "icon"]

  toggle() {
    const open = this.panelTarget.classList.toggle("hidden")
    this.iconTarget.classList.toggle("text-cuhk-gold", !open)
    this.iconTarget.classList.toggle("bg-cuhk-purple", !open)
    this.iconTarget.classList.toggle("text-gray-400", open)
    this.iconTarget.classList.toggle("bg-transparent", open)
  }
}
