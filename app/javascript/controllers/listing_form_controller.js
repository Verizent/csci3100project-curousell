import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mapPreview", "mapPlaceholder", "fileInput", "preview", "locationInput", "latInput", "lngInput"]
  static values  = { apiKey: String }

  #files = []
  #ALLOWED_TYPES = new Set(["image/jpeg", "image/png", "image/webp"])
  #MAX_IMAGES = 5
  #mapsLoadedHandler = null
  #debounceTimer = null

  connect() {
    if (window.google?.maps?.places) {
      this.#initAutocomplete()
    } else {
      this.#mapsLoadedHandler = () => this.#initAutocomplete()
      document.addEventListener("google-maps-loaded", this.#mapsLoadedHandler)
    }
  }

  disconnect() {
    if (this.#mapsLoadedHandler) {
      document.removeEventListener("google-maps-loaded", this.#mapsLoadedHandler)
      this.#mapsLoadedHandler = null
    }
  }

  #initAutocomplete() {
    const autocomplete = new google.maps.places.Autocomplete(this.locationInputTarget, {
      fields: ["geometry", "formatted_address"]
    })

    autocomplete.addListener("place_changed", () => {
      const place = autocomplete.getPlace()
      if (!place.geometry?.location) {
        this.latInputTarget.value = ""
        this.lngInputTarget.value = ""
        return
      }
      const lat = place.geometry.location.lat()
      const lng = place.geometry.location.lng()
      this.latInputTarget.value = lat
      this.lngInputTarget.value = lng
      this.#showMapPreview(lat, lng)
    })
  }

  // Called when user types manually — clears pinned coordinates
  locationChanged() {
    this.latInputTarget.value = ""
    this.lngInputTarget.value = ""
    this.mapPreviewTarget.classList.add("hidden")
    this.mapPlaceholderTarget.classList.remove("hidden")
  }

  #showMapPreview(lat, lng) {
    const src = `https://www.google.com/maps/embed/v1/place?key=${this.apiKeyValue}&q=${lat},${lng}`
    this.mapPreviewTarget.src = src
    this.mapPreviewTarget.classList.remove("hidden")
    this.mapPlaceholderTarget.classList.add("hidden")
  }

  openFilePicker() {
    this.fileInputTarget.click()
  }

  addImages(event) {
    const incoming = Array.from(event.target.files)
    const invalid = incoming.filter(f => !this.#ALLOWED_TYPES.has(f.type))
    if (invalid.length) {
      alert(`Only JPEG, PNG, and WebP images are allowed. Skipped: ${invalid.map(f => f.name).join(", ")}`)
    }
    const existing = new Set(this.#files.map(f => `${f.name}-${f.size}`))
    const slots = this.#MAX_IMAGES - this.#files.length
    const toAdd = incoming
      .filter(f => this.#ALLOWED_TYPES.has(f.type) && !existing.has(`${f.name}-${f.size}`))
      .slice(0, slots)
    if (toAdd.length < incoming.filter(f => this.#ALLOWED_TYPES.has(f.type)).length) {
      alert(`You can upload a maximum of ${this.#MAX_IMAGES} photos.`)
    }
    toAdd.forEach(f => this.#files.push(f))
    this.#syncInput()
    this.#renderPreviews()
  }

  removeImage(event) {
    const idx = parseInt(event.currentTarget.dataset.index, 10)
    const wrap = event.currentTarget.closest("[data-url]")
    if (wrap) URL.revokeObjectURL(wrap.dataset.url)
    this.#files.splice(idx, 1)
    this.#syncInput()
    this.#renderPreviews()
  }

  #syncInput() {
    const dt = new DataTransfer()
    this.#files.forEach(f => dt.items.add(f))
    this.fileInputTarget.files = dt.files
  }

  #renderPreviews() {
    const container = this.previewTarget
    container.querySelectorAll("[data-url]").forEach(el => URL.revokeObjectURL(el.dataset.url))
    container.innerHTML = ""

    this.#files.forEach((file, i) => {
      const url = URL.createObjectURL(file)
      const wrap = document.createElement("div")
      wrap.className = "relative group"
      wrap.dataset.url = url
      wrap.innerHTML = `
        <img src="${url}" alt="${file.name}"
             class="w-24 h-24 object-cover rounded-lg border border-gray-200">
        <button type="button"
                data-action="click->listing-form#removeImage"
                data-index="${i}"
                class="absolute -top-2 -right-2 w-5 h-5 rounded-full bg-red-500 text-white text-xs
                       flex items-center justify-center opacity-0 group-hover:opacity-100
                       transition-opacity leading-none">
          &times;
        </button>
        <p class="mt-1 text-xs text-gray-400 truncate w-24">${file.name}</p>
      `
      container.appendChild(wrap)
    })

    const empty = this.#files.length === 0
    container.classList.toggle("hidden", empty)
    container.classList.toggle("flex", !empty)
  }

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
