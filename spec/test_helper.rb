module Lightrail
  class TestHelper
    def self.get_last_four(code)
      return "…" + code.split(//).last(4).join("").to_s
    end
  end
end