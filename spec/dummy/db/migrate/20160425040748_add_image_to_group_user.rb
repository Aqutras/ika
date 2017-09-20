class AddImageToGroupUser < ActiveRecord::Migration[5.1]
  def change
    add_column :group_users, :image, :string
  end
end
