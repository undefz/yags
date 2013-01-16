class Contribution < ActiveRecord::Base
  belongs_to :author
  belongs_to :repo
  # attr_accessible :title, :body
  attr_accessible :repo_id, :author_id, :lines_added, :lines_deleted
  validates :repo_id, :author_id, :lines_added, :lines_deleted, presence: true
  validates :lines_added, :lines_deleted, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
