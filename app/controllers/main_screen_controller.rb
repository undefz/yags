class MainScreenController < ApplicationController
  def show
    @repos = Repo.all
  end
end
