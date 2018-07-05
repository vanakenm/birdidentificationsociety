class AddContentsToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :image_contents, :string
  end
end
