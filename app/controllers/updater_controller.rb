class UpdaterController < ApplicationController
  def update_stats
  	repo = Repo.find(params[:repo_id])

  	logger.info "Starting update of repo #{repo.name}"

  	user = Settings.github.user
  	password = Settings.github.password

  	github = Github.new login: user, password: password
    gh_user, gh_repo = repo.name.split '/'
  	commits = github.repos.commits.all gh_user, gh_repo

    gh_authors = Hash.new{|h,k| h[k]=Hash.new(0)}
    commits.each do |commit|
      commit_sha = commit.sha
      detailed_commit = github.repos.commits.get gh_user, gh_repo, commit_sha

      author = detailed_commit.commit.committer.name
      
      added = detailed_commit.stats.additions
      deleted = detailed_commit.stats.deletions

      gh_authors[:author][:name] = author
      gh_authors[:author][:added] += added
      gh_authors[:author][:deleted] += deleted
    end

    logger.info "#{gh_authors.to_json}"
  	logger.info "Finishing update of repo #{repo.name}"
  end
end
