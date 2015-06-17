class CreateGroupUsers < ActiveRecord::Migration
  def change
    create_table :group_users do |t|
      t.integer :user_id, null: false
      t.integer :group_id, null: false

      t.timestamps null: false
    end
    add_index :group_users, :user_id
    add_index :group_users, :group_id
  end
end
