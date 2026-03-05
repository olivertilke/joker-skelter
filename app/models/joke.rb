class Joke < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy

  validates :keywords, presence: true
  validates :content, presence: true

  after_create :fetch_gif

  private

  def fetch_gif
    gif_url = PunchlineGifService.new(content).call
    update_column(:gif_url, gif_url) if gif_url.present?
  end
end
