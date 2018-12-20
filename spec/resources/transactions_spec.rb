require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Values do
  subject(:factory) {Lightrail::Values}

  describe "Transaction Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]
  end
end
