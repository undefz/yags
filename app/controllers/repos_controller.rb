class ReposController < ApplicationController
  # GET /repos
  # GET /repos.json
  def index
    @repos = Repo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @repos }
    end
  end

  # GET /repos/1
  # GET /repos/1.json
  def show
    @repo = Repo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @repo }
    end
  end

  # GET /repos/new
  # GET /repos/new.json
  def new
    @repo = Repo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @repo }
    end
  end

  # GET /repos/1/edit
  def edit
    @repo = Repo.find(params[:id])
  end

  # POST /repos
  # POST /repos.json
  def create
    @repo = Repo.new(params[:repo])

    respond_to do |format|
      if @repo.save
        format.html { redirect_to @repo, notice: 'Repo was successfully created.' }
        format.json { render json: @repo, status: :created, location: @repo }
      else
        format.html { render action: "new" }
        format.json { render json: @repo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /repos/1
  # PUT /repos/1.json
  def update
    @repo = Repo.find(params[:id])

    respond_to do |format|
      if @repo.update_attributes(params[:repo])
        format.html { redirect_to @repo, notice: 'Repo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @repo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repos/1
  # DELETE /repos/1.json
  def destroy
    @repo = Repo.find(params[:id])
    @repo.destroy

    respond_to do |format|
      format.html { redirect_to repos_url }
      format.json { head :no_content }
    end
  end

  # GET /repos/1/update_stats
  # GET /repos/1/update_stats.json
  def update_stats
    repo = Repo.find(params[:id])

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

    respond_to do |format|
      format.html { redirect_to repos_url }
      format.json { head :no_content }
    end
  end
end
