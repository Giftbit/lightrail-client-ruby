module Lightrail
  class Values
    def self.create(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/values", params)
    end

    def self.get(id, query_params = {})
      # todo - check that id is not null
      # todo - url encode the id
      Lightrail::Connection.get("#{Lightrail.api_base}/values/#{id}", query_params)
    end

    # how will the paging headers work?
    def self.list(query_params = {})
      Lightrail::Connection.get("#{Lightrail.api_base}/values", query_params)
    end

    def self.update(params)

    end

    def self.change_code(params)

    end

    def self.delete(params)

    end
  end
end