class CreateSolidQueueTables < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_queue_tables do |t|
      t.timestamps
    end
  end
end

# For the cache migration:
def up
  load Rails.root.join("db/cache_schema.rb")
end
def down = raise ActiveRecord::IrreversibleMigration

# For the queue migration:
def up
  load Rails.root.join("db/queue_schema.rb")
end
def down = raise ActiveRecord::IrreversibleMigration

# For the cable migration:
def up
  load Rails.root.join("db/cable_schema.rb")
end
def down = raise ActiveRecord::IrreversibleMigration