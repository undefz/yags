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

  test "update test" do
    repo = Repo.new(name: 'juggy/ember_inspector')
    repo.save

    responses = YAML.load File.open('test/unit/repo_emul.yaml')
    responses.each do |response|
      Typhoeus.stub(response.options[:request].url).and_return(response)
    end

    repo.update_stats;
    contributions = Contribution.where(repo_id: repo.id)
    assert contributions.length == 3
    contributions.each do |contribution|
      if contribution.author.nickname == 'rapheld'
        assert contribution.lines_added == 90
        assert contribution.lines_deleted == 16
      elsif contribution.author.nickname == 'pjmorse'
        assert contribution.lines_added == 2
        assert contribution.lines_deleted == 3
      elsif contribution.author.nickname == 'juggy'
        assert contribution.lines_added == 43
        assert contribution.lines_deleted == 45
      else
        assert false
      end
    end
  end

end
