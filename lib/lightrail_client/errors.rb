module Lightrail
  class LightrailError < StandardError
    attr_reader :message, :status
    attr_accessor :response

    def initialize (message = '', status = '', response)
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