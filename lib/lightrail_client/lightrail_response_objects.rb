module Lightrail
  class LightrailResponse
    attr_reader :body, :text, :status, :links, :max_limit, :limit

    def initialize (body, text, status, links = nil, limit = nil, max_limit = nil)
      @body = body
      @text = text
      @links = links
      @status = status
      @max_limit = max_limit
      @limit = limit
    end
  end
end