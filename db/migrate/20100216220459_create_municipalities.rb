class CreateMunicipalities < ActiveRecord::Migration
  def self.up
    create_table :municipalities do |t|
      t.string :name
      t.string :kind
      t.integer :county_id
      t.datetime :deleted_at

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :municipalities
  end
end
