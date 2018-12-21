module Lightrail
  class Connection
    def self.connection
      conn = Faraday.new Lightrail.api_base, ssl: {version: :TLSv1_2}
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{Lightrail.api_key}"
      conn.headers['User-Agent'] = "Lightrail-Ruby/#{Gem.loaded_specs['lightrail_client'].version.version}"
      conn
    end

    def self.post (url, body)
      resp = Lightrail::Connection.connection.post do |req|
        req.url url
        req.body = JSON.generate(body)
      end
      self.handle_response(resp)
    end

    def self.patch (url, body)
      resp = Lightrail::Connection.connection.patch do |req|
        req.url url
        req.body = JSON.generate(body)
      end
      self.handle_response(resp)
    end

    def self.delete (url)
      resp = Lightrail::Connection.connection.delete do |req|
        req.url url
      end
      self.handle_response(resp)
    end

    def self.get(url, query_params = {})
      resp = Lightrail::Connection.connection.get {|req| req.url url, query_params}
      self.handle_response(resp, false)
    end

    def self.handle_response(response, error_on_404 = true)
      case response.status
      when 200...300
        return format_response(response)
      else
        if response.status == 404 && !error_on_404
          return format_response(response)
        end
        body = JSON.parse(response.body) || {}
        raise LightrailError.new("Server responded with: (#{response.status}) #{body['message'] || ''}", response.status, response)
      end
    end

    def self.format_response(response)
      body = JSON.parse(response.body) || {}
      text = response.body
      links, limit, max_limit = nil
      if response.headers["link"]
        links = self.parse_link_headers(response.headers["link"])
        limit = response.headers["limit"].to_i
        max_limit = response.headers["max-limit"].to_i
      end
      return LightrailResponse.new(body, text, response.status, links, limit, max_limit)
    end

    def self.parse_link_headers(link_headers)
      links = []
      link_headers.split(",").each do |link_header|
        link = {
            url: link_header[/(?<=\<)(.*?)(?=\>)/, 1],
            rel: link_header[/(?<=\")(.*?)(?=\")/, 1]
        }
        CGI::parse(URI::parse(link[:url]).query).each do |key, values|
          link[key.to_sym] = values[0] # CGI parse returns hash of key => [values]. [values] will always be of length 1 so this removes the array.
        end
        links.push(link)
      end
      return links
    end
  end
end