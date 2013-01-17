module Exceptions
  class GitHubProblemException < StandardError
  end

  class RateLimitExhausedException < StandardError
  end

  class NotExistingRepoException < StandardError
  end
end