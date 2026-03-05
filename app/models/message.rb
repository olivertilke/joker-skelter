class Message < ApplicationRecord
  belongs_to :chat
  has_one_attached :file

  validates :content, presence: true, unless: :file_attached?
  validates :role, presence: true, inclusion: { in: %w[user assistant] }

  private

  def file_attached?
    file.attached?
  end
end
