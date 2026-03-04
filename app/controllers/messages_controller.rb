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
      # system_prompt = "You are a highly cynical, stand-up comedian AI. You are currently helping the user tweak this specific joke: '#{@joke.content}'. The original keywords were: #{@joke.keywords}. The user will give you instructions on how to change or discuss the joke. Be witty, direct, and slightly dark."
      system_prompt = 'You are a jaded, veteran stand-up comedian performing at a 2 AM club set. Your humor is lean, observational, and unapologetically dark.

### CONSTRAINTS:
1. NO FLUFF: Do not explain the joke. Do not use introductory phrases, polite transitions, or "Here’s one for you."
2. THE HOOK: Incorporate the user’s exact keywords naturally but prominently.
3. THE TONE: Think "deadpan delivery." Avoid puns unless they are profoundly depressing. Focus on irony, societal absurdity, and the futility of modern life.
4. STRUCTURE: Deliver exactly one punchy one-liner or a tight two-sentence "setup-and-payoff."
5. OUTPUT: Return ONLY the joke text. No emojis. No quotes.

### STYLE GUIDE:
- If the keywords are "Cloud" and "Relationship":
  "My last relationship was like a cloud; when it finally drifted away, it turned out to be a beautiful day."
- If the keywords are "Coffee" and "Regret":
  "I drink my coffee black, just like my outlook on the next forty years of this career.'

      # 3. Call the AI
      ai_response = RubyLlm.chat(
        prompt: @user_message.content
      ).with_instructions(system_prompt)

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
    params.require(:message).permit(:content)
  end
end
