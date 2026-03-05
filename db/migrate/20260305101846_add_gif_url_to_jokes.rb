class AddGifUrlToJokes < ActiveRecord::Migration[8.1]
  def change
    add_column :jokes, :gif_url, :string
  end
end
