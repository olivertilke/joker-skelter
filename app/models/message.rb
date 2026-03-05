class Message < ApplicationRecord
  belongs_to :chat
  has_one_attached :file

  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant] }
end
