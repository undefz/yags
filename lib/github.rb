class GitHub
  def self.check_repo_existance(repo_name)
    url = "https://api.github.com/repos/#{repo_name}"
    user, password = get_credentials()
    r = Typhoeus.get url, followlocation: true, userpwd: "#{user}:#{password}"; 
    r.success?
  end

  def self.iterate_over_commits(gh_user, gh_repo, last_sha, commit_lambda)
    user, password = get_credentials()

    hydra = Typhoeus::Hydra.hydra
    next_page = create_api_url(gh_user, gh_repo)

    first_commit = nil
    e_tag = nil
    update_completed = false

    while not (update_completed or next_page.nil?)
      r = Typhoeus.get next_page, followlocation: true, userpwd: "#{user}:#{password}"
      commits = JSON.parse r.body
      e_tag = r.headers[:ETag]

      Rails.logger.debug("Reading portion of #{commits.count} commits")

      commits.each do |commit|
        Rails.logger.info("Commit class is #{commit.class}")
        commit_sha = commit['sha']
        if first_commit.nil?
          first_commit = commit_sha          
        end
        if commit_sha == last_sha
          update_completed = true
          break
        else
          request = Typhoeus::Request.new commit['url'], followlocation: true, userpwd: "#{user}:#{password}";
          request.on_complete do |response|
            commit_lambda.call(response)
          end

          
          hydra.queue(request)
        end        
      end

      hydra.run

      next_page = create_next_page_url r.headers[:Link]
    end

    return first_commit
  end

  private
  def self.get_credentials
    user, password = Settings.github.user, Settings.github.password
  end

  def self.create_api_url(repo_author, repo_name)
    url = "https://api.github.com/repos/#{repo_author}/#{repo_name}/commits?per_page=100"
  end

  def self.create_next_page_url(link)
    if not link.nil?
      if matches = link.match(/<(\S*)>;\s*rel="next"/i)
        matches.captures.first
      end
    end
  end
end