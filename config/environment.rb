# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Yags::Application.initialize!

scheduler_job = Delayed::Job.where(queue: 'scheduler').first
if scheduler_job.nil?
    #Delayed::Job.enqueue ReposUpdateJob.new(Repo.all), queue: 'scheduler'
end