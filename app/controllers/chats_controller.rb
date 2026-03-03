class ChatsController < ApplicationController
  def index
    # Shows all chats belonging to the current user (Scope 4)
    @chats = current_user.chats.order(created_at: :desc)
  end

  def create
    @joke = Joke.find(params[:joke_id])
    # We create a new chat and link it instantly to the specific joke and the user
    @chat = Chat.new(joke: @joke, user: current_user, title: "Chat about: #{@joke.keywords}")

    if @chat.save
      redirect_to chat_path(@chat), notice: "AI Assistant is ready!"
    else
      redirect_to joke_path(@joke), alert: "Could not start the chat."
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @joke = @chat.joke
    # We need an empty Message object for the input field at the bottom of the chat
    @message = Message.new
  end
end
