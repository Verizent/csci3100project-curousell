import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
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
