class RubyLlm
  def self.chat(prompt:)
    new(prompt)
  end

  def initialize(prompt)
    @prompt = prompt
    @instructions = "You are a helpful assistant." # fallback default
  end

  def with_instructions(instructions)
    @instructions = instructions
    call_openai
  end

  private

  def call_openai
    # This securely grabs the API key from your .env file
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))

    response = client.chat(
      parameters: {
        model: "gpt-4.1-nano", # Fast and easy and your momma
        messages: [
          { role: "system", content: @instructions },
          { role: "user", content: @prompt }
        ]
      }
    )

    # This digs through the OpenAI JSON response to pull out just the joke text
    response.dig("choices", 0, "message", "content")
  end
end
