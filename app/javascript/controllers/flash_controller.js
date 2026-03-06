import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
    connect() {
        // Auto-hide the flash message after 2 seconds
        setTimeout(() => {
            this.close()
        }, 2000)
    }

    close() {
        // Bootstrap fade out trick: remove 'show' class to start transition
        this.element.classList.remove("show")

        // After transition is done, remove from DOM
        setTimeout(() => {
            this.element.remove()
        }, 300) // Bootstrap default fade transition is 150ms-300ms
    }
}
