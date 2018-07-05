class CreateRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :requests do |t|
      t.string :url
      t.string :where
      t.string :phone

      t.timestamps
    end
  end
end
