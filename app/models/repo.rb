class Repo < ActiveRecord::Base
  has_many :contributions
  attr_accessible :last_commit, :name
  validates :name, presence: true
  validates :last_commit, allow_blank: true, format: {
    with: %r{[0-9a-f]{40}}i
  }

  def update_stats
    Repo.transaction do
      logger.info "Starting update of repo #{self.name}"

      gh_user, gh_repo = self.name.split '/'

      e_tag = nil
     
      contributions_patch = Hash.new{|h,k| h[k] = Hash.new(0)}

      update_patch = Proc.new do |response|
        commit = JSON.parse response.body

        unless commit['author'].nil?
          added = commit['stats']['additions']
          deleted = commit['stats']['deletions']
          author = commit['author']['login']

          contributions_patch[author][:added] += added
          contributions_patch[author][:deleted] += deleted
        end
      end    

      self.last_commit = GitHub.iterate_over_commits gh_user, gh_repo, self.last_commit, update_patch

      logger.info "#{contributions_patch.to_json}"
      patch_contribution(contributions_patch)

      self.save
      logger.info "Finishing update of self #{self.name}"
    end
  end

  private

  def patch_contribution(contributions_patch)
    contributions_patch.each do |author_name, stats|
      author = Author.find_or_create_by_nickname(author_name)

      contribution = Contribution.where(repo_id: self.id, author_id: author.id).first
      contribution ||= Contribution.create repo_id: self.id, author_id: author.id
      
      contribution.lines_added = stats[:added] + (contribution.lines_added || 0)
      contribution.lines_deleted = stats[:deleted] + (contribution.lines_deleted || 0)
      contribution.save
    end
  end
end
