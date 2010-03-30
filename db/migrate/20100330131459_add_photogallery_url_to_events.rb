class AddPhotogalleryUrlToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :photogallery_url, :text
  end

  def self.down
    remove_column :events, :photogallery_url
  end
end
