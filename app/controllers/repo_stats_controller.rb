class RepoStatsController < ApplicationController
  def show
    @repo =  nil

    if params[:repo_id]
      begin  
        @repo = Repo.find(params[:repo_id])
      rescue ActiveRecord::RecordNotFound
      end
    elsif params[:repo_name]
      input_repo_name = params[:repo_name]
      validation_regexp = 'https://github.com/?([a-zA-Z0-9\-\._]+)/([a-zA-Z0-9\-\._]+)/?'
      matches = input_repo_name.match(validation_regexp)
      
      if not matches.nil?
        repo_name = matches.captures.join('/')
        @repo = Repo.where(name: repo_name).first
        @repo_just_created = @repo.nil?
        if @repo.nil? and GitHub.check_repo_existance(repo_name)
          @repo = Repo.create(name: repo_name)
          @repo.delay.update_stats
        end
      end
      
    end

    if not @repo.nil?
      logger.debug("#{@repo.to_json}")
      @top_add_contribs = Contribution.where(repo_id: @repo.id).order('lines_added').reverse_order.includes(:author).limit(10)
      @top_delete_contribs = Contribution.where(repo_id: @repo.id).order('lines_deleted').reverse_order.includes(:author).limit(10)
      logger.debug("#{@top_add_contribs.to_json}")
      logger.debug("#{@top_delete_contribs.to_json}")
    else
      redirect_to main_screen_show_path alert: true
    end
  end
end
