class Tags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, null: false, default: ''
      t.integer :group_id, null: false

      t.timestamps null: false
    end
  end
end
