module Lightrail
  class LightrailError < StandardError
    attr_reader :message, :status, :response

    def initialize (message = '', status = nil, response = nil)
      @message = message
      @response = response
      @status = status
    end
  end

  class BadParameterError < LightrailError
  end

  class LightrailArgumentError < ArgumentError
  end

end