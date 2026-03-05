class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @joke = @chat.joke

    # 1. Save the user's message
    @user_message = Message.new(message_params)
    @user_message.chat = @chat
    @user_message.role = "user" # Extremely important for the AI!

    if @user_message.save

      # 2. Define the Business Asset System Prompt
      # VETO-RULE: We MUST inject the joke content here, otherwise the AI is blind!
      system_prompt = <<~PROMPT
        You are a hilarious, immature stand-up comedian who specializes in low-brow, toilet humor. You are currently helping the user tweak their joke, but keep your responses funny, gross, and unapologetically full of bathroom jokes, farts, and bodily functions.

        ### CONSTRAINTS:
        1. NO FLUFF: Do not explain the joke. Do not use introductory phrases, polite transitions, or "Here's one for you."
        2. THE HOOK: Incorporate the user's exact keywords naturally but prominently.
        3. THE TONE: Think "middle school locker room." Use plenty of bathroom humor, potty jokes, fart references, and gross-out comedy. Make it genuinely funny but incredibly immature.
        4. STRUCTURE: Deliver exactly one punchy one-liner or a tight two-sentence "setup-and-payoff" if they ask for a joke, or just be a gross degenerate when answering questions.
        5. OUTPUT: Return ONLY the joke text or response. No emojis. No quotes.

        ### STYLE GUIDE:
        - If the keywords are "Cloud" and "Relationship":
          "My last relationship was like a silent fart; it crept up on me and suffocated everything good in the room."
        - If the keywords are "Coffee" and "Regret":
          "I drink my coffee black, mostly because it speeds up the explosive diarrhea I need to get out of this meeting."
      PROMPT

      # 3. Call the AI — branch on whether a file was uploaded
      if @user_message.file.attached?
        ai_response = FileProcessor.call(@user_message.file, @user_message.content, system_prompt)
      else
        ai_response = RubyLlm.chat(
          prompt: @user_message.content
        ).with_instructions(system_prompt)
      end

      # 4. Instantly save the AI's response as a new Message
      Message.create!(
        chat: @chat,
        role: "assistant",
        content: ai_response
      )

      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :file)
  end
end
