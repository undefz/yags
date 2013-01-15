class Repo < ActiveRecord::Base
  has_many :contributions
  attr_accessible :last_commit, :name

  def update_stats
    logger.info "Starting update of repo #{self.name}"

    user = Settings.github.user
    password = Settings.github.password

    gh_user, gh_repo = self.name.split '/'

    hydra = Typhoeus::Hydra.hydra
    next_page = create_api_url(gh_user, gh_repo)

    first_commit = nil
    e_tag = nil
    update_completed = false
    
    while not (update_completed or next_page.nil?)
      r = Typhoeus.get next_page, followlocation: true, userpwd: "#{user}:#{password}"
      commits = JSON.parse r.body
      e_tag = r.headers[:ETag]

      logger.info("Reading portion of #{commits.count} commits")

      requests = []
      commits.each do |commit|
        commit_sha = commit['sha']
        if first_commit.nil?
          first_commit = commit_sha          
        end
        if commit_sha == self.last_commit
          update_completed = true
          break
        else
          request = Typhoeus::Request.new commit['url'], followlocation: true, userpwd: "#{user}:#{password}";
          requests << request;
          hydra.queue(request)
        end        
      end

      hydra.run

      gh_authors = Hash.new{|h,k| h[k] = Hash.new(0)}
      requests.each do |request|
        commit = JSON.parse request.response.body

        unless commit['author'].nil?
          added = commit['stats']['additions']
          deleted = commit['stats']['deletions']
          author = commit['author']['login']

          gh_authors[author][:added] += added
          gh_authors[author][:deleted] += deleted
        end      
      end

      logger.info "#{gh_authors.to_json}"

      patch_contribution(gh_authors)

      next_page = create_next_page_url r.headers[:Link]
    end

    self.last_commit = first_commit
    self.save
    logger.info "Finishing update of self #{self.name}"

  end

  private
  def create_api_url(repo_author, repo_name, sha=nil)
    url = "https://api.github.com/repos/#{repo_author}/#{repo_name}/commits?per_page=100"
  end

  def create_next_page_url(link)
    if not link.nil?
      if matches = link.match(/<(\S*)>;\s*rel="next"/i)
        matches.captures.first
      end
    end
  end

  def patch_contribution(gh_authors)
    gh_authors.each do |author_name, stats|
      author = Author.find_or_create_by_nickname(author_name)

      contribution = Contribution.where(repo_id: self.id, author_id: author.id).first
      contribution ||= Contribution.create repo_id: self.id, author_id: author.id
      
      contribution.lines_added = stats[:added] + (contribution.lines_added || 0)
      contribution.lines_deleted = stats[:deleted] + (contribution.lines_deleted || 0)
      contribution.save
    end
  end
end
