class Contribution < ActiveRecord::Base
  belongs_to :author
  belongs_to :repo
  # attr_accessible :title, :body
end
