require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "author should have a name" do
    author = Author.new
    assert author.invalid?
    assert author.errors[:nickname].any?
  end

  test "normal author" do
    author = Author.new(nickname: 'Andy')
    assert author.valid?
  end
end
