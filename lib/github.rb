class GitHub
  def self.check_repo_existance(repo_name)
    url = "https://api.github.com/repos/#{repo_name}"
    user, password = get_credentials()
    r = Typhoeus.get url, followlocation: true, userpwd: "#{user}:#{password}"; 
    #There is probability rate limit reached, in that case repo will be unvalidated during update
    return r.code != 404
  end

  def self.iterate_over_commits(gh_user, gh_repo, last_sha, etag, commit_lambda)
    Rails.logging.info "Starting reading commits for #{gh_user}/#{gh_repo}"
    user, password = get_credentials()

    hydra = Typhoeus::Hydra.hydra
    next_page = create_api_url gh_user, gh_repo

    first_commit = nil
    
    update_completed = false

    while not (update_completed or next_page.nil?)
      Rails.logging.debug "Asking github api for url #{next_page}"
      commit_request = Typhoeus::Request.new next_page, followlocation: true, userpwd: "#{user}:#{password}"
      if first_commit.nil? and not etag.nil?
        commit_request.options[:headers]['If-None-Match']=etag
      end
      commit_request.run

      commit_response = commit_request.response

      unless commit_response.success?
        if commit_response.code == 404
          Rails.logging.error "Repository #{gh_user}/#{gh_repo} doesn't exist!"
          raise Exceptions::NotExistingRepoException
        elsif commit_response.code == 403
          Rails.logging.info "Rate limit reached, aborting execution"
          raise Exceptions::RateLimitExhausedException
        elsif commit_response.code == 304
          #Etag worked, no changes
          Rails.logging.debug "Etag valid response for repo #{gh_user}/#{gh_repo}, no changes"
          return last_sha, etag
        else
          Rails.logging.error "Unidentified response from github, aborting"
          raise Exceptions::GitHubProblemException
        end
      end

      commits = JSON.parse commit_response.body
      

      Rails.logger.debug "Reading portion of #{commits.count} commits"

      commits.each do |commit|
        commit_sha = commit['sha']
        if first_commit.nil?
          first_commit = commit_sha
          etag = commit_response.headers[:ETag]
        end
        if commit_sha == last_sha
          update_completed = true
          break
        else
          request = Typhoeus::Request.new commit['url'], followlocation: true, userpwd: "#{user}:#{password}";
          request.on_complete do |response|
            unless response.success?
              if response.code == 403
                Rails.logging.info "Rate limit reached, aborting execution"
                raise Exceptions::RateLimitExhausedException
              else
                Rails.logging.error "Unidentified response from GitHub, aborting"
                raise Exceptions::GitHubProblemException
              end
            end
            commit_lambda.call response
          end

          
          hydra.queue request
        end        
      end

      hydra.run

      next_page = create_next_page_url commit_response.headers['Link']
      
    end

    Rails.logging.info "Repository #{gh_user}/#{gh_repo} updated successfully"
    return first_commit, etag
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