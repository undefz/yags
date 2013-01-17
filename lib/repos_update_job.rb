class ReposUpdateJob < Struct.new()
  def perform
    Repo.find_each do |repo|
      repo.delay.update_stats
    end

    #Delayed::Job.enqueue ReposUpdateJob.new, queue: 'scheduler', run_at: (DateTime.now + 1.hours)
  end
end