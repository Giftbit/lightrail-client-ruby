module Lightrail
  class LightrailError < StandardError
    attr_reader :message
    attr_accessor :response

    def initialize (message='', response)
      @message = message
      @response = response
    end
  end

  class BadParameterError < LightrailError
  end

  class LightrailArgumentError < ArgumentError
  end

end