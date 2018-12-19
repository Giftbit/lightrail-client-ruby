module Lightrail
  class LightrailError < StandardError
    attr_reader :message, :status, :response
    # attr_accessor :response # todo - why was this done as attr_accessor?

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