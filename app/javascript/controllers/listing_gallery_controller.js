import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainImage", "thumbnail"]

  show(event) {
    const clicked = event.currentTarget
    this.mainImageTarget.src = clicked.dataset.fullSrc
    this.thumbnailTargets.forEach(t => {
      t.classList.toggle("border-cuhk-gold", t === clicked)
      t.classList.toggle("border-gray-200", t !== clicked)
    })
  }
}
