class Repo < ActiveRecord::Base
  has_many :contributions
  attr_accessible :last_commit, :name
end
