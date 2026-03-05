class AddGifUrlToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :gif_url, :string
  end
end
