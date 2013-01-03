class RepoStatsController < ApplicationController
  def show
    repo_name = params[:repo_name]
    @repo = Repo.where(name: repo_name).first
    if @repo.nil?
      @repo = Repo.create(name: repo_name)
      @repo.delay.update_stats
    end
    logger.info("#{@repo.to_json}")
    @top_add_contribs = Contribution.where(repo_id: @repo.id).order('lines_added').reverse_order.includes(:author).limit(10)
    @top_delete_contribs = Contribution.where(repo_id: @repo.id).order('lines_deleted').reverse_order.includes(:author).limit(10)
    logger.info("#{@top_add_contribs.to_json}")
    logger.info("#{@top_delete_contribs.to_json}")
  end
end
