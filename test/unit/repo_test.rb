require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "repo name should not be empty" do
    repo = Repo.new
    assert repo.invalid?
    assert repo.errors[:name].any?
    assert repo.errors[:last_commit].none?
  end

  test "normal repo" do
    repo = Repo.new(name: 'nkohari/jwalk', last_commit: 'cf5bce333b820a750fe3b0f93a76cd94491268da')
    assert repo.valid?
  end

  test "invalid repo last commit" do
    repo = Repo.new(name: 'aaa/bbb', last_commit: 'abcd')
    assert repo.invalid?
    assert repo.errors[:last_commit].any?
  end

end
