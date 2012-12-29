class Repo < ActiveRecord::Base
  attr_accessible :last_commit, :name
end
