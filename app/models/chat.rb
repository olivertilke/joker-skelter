class Chat < ApplicationRecord
  belongs_to :joke
  belongs_to :user
  has_many :messages, dependent: :destroy
end
