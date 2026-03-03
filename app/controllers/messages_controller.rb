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
      system_prompt = "You are a highly cynical, stand-up comedian AI. You are currently helping the user tweak this specific joke: '#{@joke.content}'. The original keywords were: #{@joke.keywords}. The user will give you instructions on how to change or discuss the joke. Be witty, direct, and slightly dark."

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
