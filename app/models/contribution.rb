class Contribution < ActiveRecord::Base
  belongs_to :author
  belongs_to :repo
  # attr_accessible :title, :body
  attr_accessible :repo_id, :author_id, :lines_added, :lines_deleted
end
