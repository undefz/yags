class ReposUpdateJob < Struct.new(:repos)
  def perform
    start_date = DateTime.now
    repos.each do |repo|
      repo.delay.update_stats
    end

    Delayed::Job.enqueue ReposUpdateJob.new(repos), queue: 'scheduler', run_at: (start_time + 1.hours)
  end
end