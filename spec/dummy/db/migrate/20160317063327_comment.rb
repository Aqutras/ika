class Comment < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.string :name, null: false, default: ''
      t.string :comment, null: false, default: ''
      t.integer :tag_id, null: false

      t.timestamps null: false
    end
  end
end
