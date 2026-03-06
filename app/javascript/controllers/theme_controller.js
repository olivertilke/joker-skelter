import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "select" ]

  connect() {
    const savedTheme = localStorage.getItem("theme") || "dark"
    this.applyTheme(savedTheme)
    if (this.hasSelectTarget) {
      this.selectTarget.value = savedTheme
    }
  }

  change(event) {
    const theme = event.target.value
    localStorage.setItem("theme", theme)
    
    const link = document.getElementById("theme-stylesheet")
    if (link) {
      if (theme === "ugly-vomit") {
        link.href = document.head.querySelector('meta[name="theme-ugly-vomit-url"]').content;
        document.documentElement.setAttribute('data-theme', 'ugly-vomit');
      } else {
        link.href = document.head.querySelector('meta[name="theme-dark-url"]').content;
        document.documentElement.removeAttribute('data-theme');
      }
    }
  }
}
