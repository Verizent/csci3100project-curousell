import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mapPreview", "mapPlaceholder"]
  static values  = { apiKey: String }

  #debounceTimer = null

  previewLocation(event) {
    const query = event.target.value.trim()
    clearTimeout(this.#debounceTimer)

    if (!query) {
      this.mapPreviewTarget.classList.add("hidden")
      this.mapPlaceholderTarget.classList.remove("hidden")
      return
    }

    this.#debounceTimer = setTimeout(() => {
      const src = `https://www.google.com/maps/embed/v1/place?key=${this.apiKeyValue}&q=${encodeURIComponent(query + ", Hong Kong")}`
      this.mapPreviewTarget.src = src
      this.mapPreviewTarget.classList.remove("hidden")
      this.mapPlaceholderTarget.classList.add("hidden")
    }, 600)
  }

  toggleFaculty(event) {
    const faculty = event.target.value
    const section = this.element.querySelector(`[data-faculty-section="${CSS.escape(faculty)}"]`)
    if (!section) return

    if (event.target.checked) {
      section.classList.remove("hidden")
    } else {
      section.classList.add("hidden")
      section.querySelectorAll('input[type="checkbox"]').forEach(cb => cb.checked = false)
    }
  }
}
