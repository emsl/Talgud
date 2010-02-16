class CreateSettlements < ActiveRecord::Migration
  def self.up
    create_table :settlements do |t|
      t.string :name
      t.string :kind
      t.integer :municipality_id
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :settlements
  end
end
