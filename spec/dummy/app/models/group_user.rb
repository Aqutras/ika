class GroupUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  mount_uploader :image, ImageUploader
end
