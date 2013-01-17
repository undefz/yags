class ReposUpdateJob
  def self.perform
    Repo.find_each do |repo|
      repo.delay.update_stats
    end
    puts 'Completed creating jobs'
  end
end