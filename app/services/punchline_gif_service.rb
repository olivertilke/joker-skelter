require "net/http"
require "json"

class PunchlineGifService
  GIPHY_SEARCH_URL = "https://api.giphy.com/v1/gifs/search"
  OPENAI_KEYWORD_PROMPT = <<~PROMPT
    You are a keyword extractor. The user will give you a joke. Extract between 1 and 3
    of the most visually evocative, concrete keywords or short phrases from the joke's
    punchline or the joke overall. These keywords will be used to search for an animated GIF,
    so pick words that would make a funny and relevant GIF (e.g. "fart", "explosion", "boss",
    "toilet"). Return ONLY the keywords as a comma-separated list. No explanation, no punctuation
    other than the commas, no quotes.
  PROMPT

  def initialize(joke_content)
    @joke_content = joke_content
  end

  def call
    keywords = extract_keywords
    return nil if keywords.blank?

    fetch_gif_url(keywords)
  rescue StandardError => e
    Rails.logger.error("[PunchlineGifService] Error: #{e.message}")
    nil
  end

  private

  def extract_keywords
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
    response = client.chat(
      parameters: {
        model: "gpt-4.1-nano",
        messages: [
          { role: "system", content: OPENAI_KEYWORD_PROMPT },
          { role: "user", content: @joke_content }
        ],
        max_tokens: 30,
        temperature: 0.5
      }
    )
    response.dig("choices", 0, "message", "content").to_s.strip
  rescue StandardError => e
    Rails.logger.error("[PunchlineGifService] Keyword extraction failed: #{e.message}")
    nil
  end

  def fetch_gif_url(keywords)
    uri = URI(GIPHY_SEARCH_URL)
    uri.query = URI.encode_www_form(
      api_key: ENV.fetch("GIPHY_API_KEY"),
      q: keywords,
      limit: 5,
      rating: "pg-13",
      lang: "en"
    )

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    gifs = data.dig("data")
    return nil if gifs.blank?

    # Pick a random one from the top 5 for variety
    gif = gifs.sample
    gif.dig("images", "original", "url")
  rescue StandardError => e
    Rails.logger.error("[PunchlineGifService] GIPHY fetch failed: #{e.message}")
    nil
  end
end
