class Tag < ActiveRecord::Base
  belongs_to :groups
  has_many :comments
end
