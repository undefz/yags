def new_update:
  puts 'User'
  user = gets.chomp
  puts 'Password'
  password = gets.chomp


  url = 'https://api.github.com/repos/collectiveidea/delayed_job/commits?per_page=100';
  r = Typhoeus.get url, followlocation: true, userpwd: "#{user}:#{password}"; 
  commits = JSON.parse r.body;
  etag = r.headers[:ETag]
  last_sha = commits.first['sha']

  hydra = Typhoeus::Hydra.hydra

  requests = []

  commits.each do |commit|
    request = Typhoeus::Request.new commit['url'], followlocation: true, userpwd: "#{user}:#{password}";
    requests << request;
    hydra.queue(request); 
  end
  hydra.run

  requests.each do |request|
    response = JSON.parse request.response.body
    response['stats']['additions']
    response['stats']['deletions']
    response['committer']['login']
  end
end