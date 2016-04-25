class AddImageToGroupUser < ActiveRecord::Migration
  def change
    add_column :group_users, :image, :string
  end
end
