class Joke < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy

  validates :keywords, presence: true
  validates :content, presence: true
end
