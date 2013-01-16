class Author < ActiveRecord::Base
  attr_accessible :nickname
  validates :nickname, presence: true
end
