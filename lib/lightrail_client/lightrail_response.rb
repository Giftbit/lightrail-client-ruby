module Lightrail
  class LightrailResponse
    attr_reader :body, :status, :links, :max_limit, :limit

    def initialize (body, status, links = nil, limit = nil, max_limit = nil)
      @body = body
      @links = links
      @status = status
      @max_limit = max_limit
      @limit = limit
    end
  end
end