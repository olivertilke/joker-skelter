import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tts"
export default class extends Controller {
  static values = { text: String }

  speak(event) {
    event.preventDefault()

    if (!window.speechSynthesis) {
      alert("Your browser doesn't support Text-to-Speech!")
      return
    }

    // Cancel any ongoing speech
    window.speechSynthesis.cancel()

    const utterance = new SpeechSynthesisUtterance(this.textValue)

    // Add "funny" characteristics: higher pitch, slightly faster rate
    utterance.pitch = 1.7
    utterance.rate = 1.1

    // Try to find a distinct voice (like "Google UK English Female" or something recognizable)
    const voices = window.speechSynthesis.getVoices()
    if (voices.length > 0) {
      // Very basic attempt: just pick the first one that isn't the absolute default if possible,
      // or specifically look for one with "Female" or "UK" in it for comedic variety.
      const funnyVoice = voices.find(v => v.name.includes("UK") || v.name.includes("Female"))
      if (funnyVoice) {
        utterance.voice = funnyVoice
      }
    }

    // 🎤 When the joke finishes being read, fire the canned laughter!
    utterance.onend = () => {
      this.playCannedLaughter()
    }

    window.speechSynthesis.speak(utterance)
  }

  playCannedLaughter() {
    const audio = new Audio("/canned_laughter.mp3")
    audio.play().catch(err => {
      // Silently fail if audio can't play (e.g. browser autoplay policy)
      console.warn("Canned laughter couldn't play:", err)
    })

    // Stop playback after 5 seconds
    setTimeout(() => {
      audio.pause()
      audio.currentTime = 0
    }, 5000)
  }
}
