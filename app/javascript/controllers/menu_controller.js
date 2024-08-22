// app/javascript/controllers/menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.setActiveItem()
    document.addEventListener("turbo:frame-load", this.setActiveItem.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.setActiveItem.bind(this))
  }

  setActiveItem() {
    if (document.querySelector('.article-list')) {
        let activeId = document.querySelector('.article-list').id

        this.itemTargets.forEach(item => {
            if (item.dataset.feedId === activeId) {
                item.classList.add('is-active')
            } else {
                item.classList.remove('is-active')
            }
        })
    }
  }
}