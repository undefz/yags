require 'test_helper'

class ContributionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "contribution fields must be filled" do
    contribution = Contribution.new
    contribution.invalid?
    contribution.errors[:repo_id].any?
    contribution.errors[:author_id].any?
    contribution.errors[:lines_added].any?
    contribution.errors[:lines_deleted].any?
  end

  test "authors contributions should be positive" do
    contribution = Contribution.new(repo_id: 1, author_id: 1, lines_added: -5, lines_deleted: -6)
    contribution.invalid?
    contribution.errors[:lines_added].any?
    contribution.errors[:lines_deleted].any?
  end

  test "valid contribution check" do
    contribution = Contribution.new(repo_id: 1, author_id: 1, lines_added: 0, lines_deleted: 15)
    contribution.valid?
  end
end
