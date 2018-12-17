module Lightrail
  class Values
    def self.create(params)
      Lightrail::Connection.post("https://api.lightrail.com/v2/values", params)
    end

    def self.get(params)

    end

    def self.list(params)

    end

    def self.update(params)

    end

    def self.change_code(params)

    end

    def self.delete(params)

    end
  end
end