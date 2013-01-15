class ApplicationController < ActionController::Base
  protect_from_forgery

  def get_github_credentials
    user = Settings.github.user
    password = Settings.github.password

    return user, password
  end
end
