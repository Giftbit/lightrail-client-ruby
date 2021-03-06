require "spec_helper"

RSpec.describe Lightrail do
  it "has a version number" do
    expect(Lightrail::VERSION).not_to be nil
  end

  it "stores the base URL for the Lightrail API" do
    expect(Lightrail.api_base).to eq('https://dev.lightrail.com/v2').or(eq('https://api.lightrail.com/v2'))
  end
end
