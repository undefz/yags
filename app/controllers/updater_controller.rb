class UpdaterController < ApplicationController
  def update_stats
  	repo = Repo.find(params[:repo_id])
  end
end
