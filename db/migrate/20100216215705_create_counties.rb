class CreateCounties < ActiveRecord::Migration
  def self.up
    create_table :counties do |t|
      t.string :name

      t.datetime :deleted_at
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :counties
  end
end
