import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["boughtTab", "soldTab", "boughtSection", "soldSection"]

  connect() {
    this.showBought()
  }

  showBought() {
    this.boughtSectionTarget.classList.remove("hidden")
    this.soldSectionTarget.classList.add("hidden")
    this.updateTabClasses(this.boughtTabTarget, this.soldTabTarget)
  }

  showSold() {
    this.soldSectionTarget.classList.remove("hidden")
    this.boughtSectionTarget.classList.add("hidden")
    this.updateTabClasses(this.soldTabTarget, this.boughtTabTarget)
  }

  updateTabClasses(activeTab, inactiveTab) {
    activeTab.classList.add(...activeTab.dataset.activeClass.split(" "))
    activeTab.classList.remove(...activeTab.dataset.inactiveClass.split(" "))
    inactiveTab.classList.remove(...inactiveTab.dataset.activeClass.split(" "))
    inactiveTab.classList.add(...inactiveTab.dataset.inactiveClass.split(" "))
  }

  filterStatus(event) {
    const selectedStatus = event.target.value
    const currentSection = this.boughtSectionTarget.classList.contains("hidden") ? this.soldSectionTarget : this.boughtSectionTarget
    const orders = currentSection.querySelectorAll("[data-status]")

    orders.forEach(order => {
      if (selectedStatus === "" || order.dataset.status === selectedStatus) {
        order.style.display = ""
      } else {
        order.style.display = "none"
      }
    })
  }
}