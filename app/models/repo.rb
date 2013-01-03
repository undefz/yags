class Repo < ActiveRecord::Base
  has_many :contributions
  attr_accessible :last_commit, :name

  def update_stats
    repo = self
    logger.info "Starting update of repo #{repo.name}"

    user = Settings.github.user
    password = Settings.github.password

    github = Github.new login: user, password: password
    gh_user, gh_repo = repo.name.split '/'

    if repo.last_commit.nil? or repo.last_commit.empty?
      commits = github.repos.commits.all gh_user, gh_repo
    else
      commits = github.repos.commits.list gh_user, gh_repo, sha: repo.last_commit
      #this commit was already indexed
      commits.delete_at(0)
    end
    

    gh_authors = Hash.new{|h,k| h[k] = Hash.new(0)}
    commit_sha = nil
    commits.each do |commit|
      commit_sha = commit.sha
      detailed_commit = github.repos.commits.get gh_user, gh_repo, commit_sha

      author = detailed_commit.commit.committer.name
      
      added = detailed_commit.stats.additions
      deleted = detailed_commit.stats.deletions

      gh_authors[author][:added] += added
      gh_authors[author][:deleted] += deleted
    end

    logger.info "#{gh_authors.to_json}"

    if commit_sha
      repo.last_commit = commit_sha
      repo.save
    end

    gh_authors.each do |author_name, stats|
      author = Author.where(nickname: author_name).first
      unless author
        author = Author.create nickname: author_name
      end

      contribution = Contribution.where(repo_id: repo.id, author_id: author.id).first
      contribution ||= Contribution.create repo_id: repo.id, author_id: author.id
      
      contribution.lines_added = stats[:added] + (contribution.lines_added || 0)
      contribution.lines_deleted = stats[:deleted] + (contribution.lines_deleted || 0)
      contribution.save
    end

    
    logger.info "Finishing update of repo #{repo.name}"
  end
end
