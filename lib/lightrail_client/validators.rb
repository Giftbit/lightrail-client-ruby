module Lightrail
  class Validators
    def self.validate_id(id, key = "id")
      raise Lightrail::BadParameterError.new("Argument #{key} must be set.") unless ((id.is_a? String) || (id.is_a? Integer))
    end
  end
end