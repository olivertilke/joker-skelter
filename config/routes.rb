Rails.application.routes.draw do
  get "jokes/new"
  get "jokes/create"
  # Devise routes for User authentication (Sign up, login, etc.)
  devise_for :users

  # The root page (Visitor sees value proposition)
  root to: "pages#home"

  # Jokes routes (Browsing, creating, deleting)
  resources :jokes, only: [:index, :show, :new, :create, :destroy] do
    # Nested chat creation: A chat must belong to a specific joke
    resources :chats, only: [:new, :create]
  end

  # Chat & Message routes
  resources :chats, only: [:index, :show] do
    # You only need to create messages inside a chat
    resources :messages, only: [:create]
  end
end
