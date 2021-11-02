class AddPublishedToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :published, :boolean, default: false, null: false
  end
end
