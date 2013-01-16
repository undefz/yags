require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  test "check for existing repo" do
    response = YAML.load File.open('test/unit/repo.yaml')
    Typhoeus.stub(response.request.url).and_return(response)

    assert GitHub.check_repo_existance('juggy/ember_inspector')
  end

  test "check for nonexisting repo" do
    response = YAML.load File.open('test/unit/repo404.yaml')
    Typhoeus.stub(response.request.url).and_return(response)

    assert (not GitHub.check_repo_existance('juggy/ember_inspector1'))
  end

  test "commit iteration 404" do
  end

  test "commit iteration rate limit" do
  end


  test "commit iteration all" do
    YAML::ENGINE.yamler = 'syck'
    responses = YAML.load File.open('test/unit/repo_emul.yaml')
    responses.each do |response|
      Typhoeus.stub(response.options[:request].url).and_return(response)
    end

    valid_commits = [
      'dc02902e82eebac6b12aff41cfed449b99d829e7',
      '9bc689abe8bdd3d32409d9235c24c6f08c021c18',
      '9ce94317b4975d02c4b434cc2a4de978ab4c934b',
      'f7e27873e53c4992187b89d19720363bd6e860a3',
      '9e0222c05c1fcd3deddcf1b8f2fc31a7ccda2325',
      '516a4e522a8e58a49d5f2e9baa5273b1275a9eac',
      '9db80495f657bdce8c3af34d8c1266a2659d5061',
      '93b55be11847179fbdf1e4e70a13e01f27f770f1',
      'a20bdb2ad3c11cb13bd87dafb75619ac9cb92871']

    received_commits = []
    commit_lambda = Proc.new do |response|
      commit = JSON.parse response.body
      received_commits << commit['sha']
    end

    GitHub.iterate_over_commits('juggy', 'ember_inspector', nil, commit_lambda)

    Rails.logger.info "Got commits #{received_commits}"
    assert valid_commits.sort == received_commits.sort
  end

  test "commit iteration since sha" do
  end

end