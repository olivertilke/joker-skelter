class FileProcessor
  def self.call(file, prompt, system_prompt)
    new(file, prompt, system_prompt).process
  end

  def initialize(file, prompt, system_prompt)
    @file = file
    @prompt = prompt.presence || "What do you think of this?"
    @system_prompt = system_prompt
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
  end

  def process
    content_type = @file.content_type.to_s

    if content_type.start_with?("image/")
      process_image
    elsif content_type == "application/pdf"
      process_pdf
    elsif content_type.start_with?("audio/")
      process_audio
    else
      "Sorry, that file type isn't supported. Try an image, PDF, or audio file."
    end
  rescue StandardError => e
    Rails.logger.error("FileProcessor error: #{e.message}")
    "Sorry, I couldn't process that file. Please try again."
  end

  private

  # --- IMAGE: base64 vision via gpt-4o ---
  def process_image
    blob = @file.blob
    base64_data = Base64.strict_encode64(blob.download)
    mime_type = blob.content_type

    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: @system_prompt },
          {
            role: "user",
            content: [
              { type: "text", text: @prompt },
              {
                type: "image_url",
                image_url: { url: "data:#{mime_type};base64,#{base64_data}" }
              }
            ]
          }
        ]
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  # --- PDF: extract text, send as plain prompt ---
  def process_pdf
    require "pdf-reader"

    text = ""
    @file.blob.open do |tmpfile|
      reader = PDF::Reader.new(tmpfile.path)
      text = reader.pages.map(&:text).join("\n")
    end

    return "That PDF appears to be empty or image-only — I can't read it as text." if text.strip.empty?

    augmented_prompt = "#{@prompt}\n\nHere is the content of the uploaded PDF:\n\n#{text.truncate(8000)}"

    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: @system_prompt },
          { role: "user", content: augmented_prompt }
        ]
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  # --- AUDIO: Whisper transcription → then joke AI ---
  def process_audio
    transcript = nil

    @file.blob.open do |tmpfile|
      # Whisper needs the correct extension to detect format
      ext = File.extname(@file.blob.filename.to_s).downcase
      tmpfile_with_ext = "#{tmpfile.path}#{ext}"
      FileUtils.cp(tmpfile.path, tmpfile_with_ext)

      response = @client.audio.transcriptions.create(
        parameters: {
          model: "whisper-1",
          file: File.open(tmpfile_with_ext)
        }
      )

      FileUtils.rm_f(tmpfile_with_ext)
      transcript = response["text"]
    end

    if transcript.blank?
      return "I couldn't make out anything in that audio. Try speaking more clearly, unlike your last joke."
    end

    augmented_prompt = "#{@prompt}\n\nHere is the transcript of the uploaded audio:\n\n#{transcript}"

    response = @client.chat(
      parameters: {
        model: "gpt-4.1-nano",
        messages: [
          { role: "system", content: @system_prompt },
          { role: "user", content: augmented_prompt }
        ]
      }
    )

    response.dig("choices", 0, "message", "content")
  end
end
