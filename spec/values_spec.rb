require "spec_helper"
require Lightrail::Values

RSpec.describe Lightrail::Values do
  subject(:factory) {Lightrail::Values}

  let(:example_api_key) {'eyJ2ZXIiOjMsInZhdiI6MSwiYWxnIjoiSFMyNTYiLCJ0eXAiOiJKV1QifQ.eyJnIjp7Imd1aSI6InVzZXItOGM5OTlmODlhMzg3NGU0Mzg2M2QxYjAzN2IzNDU5ZDktVEVTVCIsImdtaSI6InVzZXItOGM5OTlmODlhMzg3NGU0Mzg2M2QxYjAzN2IzNDU5ZDktVEVTVCIsInRtaSI6InVzZXItOGM5OTlmODlhMzg3NGU0Mzg2M2QxYjAzN2IzNDU5ZDktVEVTVCJ9LCJhdWQiOiJBUElfS0VZIiwiaXNzIjoiU0VSVklDRVNfVjEiLCJpYXQiOjE1MzMyMzIyNjQuMDQ0LCJqdGkiOiJiYWRnZS1iNmZhNWQxNTQ4MjU0Y2M0OTM2MjMyZDEwMjY5NWJiMiIsInBhcmVudEp0aSI6ImJhZGdlLTlmNDZiMTZiNjJjODRlY2NiZmFmMjY5ZmI5ZmI3NmIyIiwic2NvcGVzIjpbXSwicm9sZXMiOlsiYWNjb3VudE1hbmFnZXIiLCJjb250YWN0TWFuYWdlciIsImN1c3RvbWVyU2VydmljZU1hbmFnZXIiLCJjdXN0b21lclNlcnZpY2VSZXByZXNlbnRhdGl2ZSIsInBvaW50T2ZTYWxlIiwicHJvZ3JhbU1hbmFnZXIiLCJwcm9tb3RlciIsInJlcG9ydGVyIiwic2VjdXJpdHlNYW5hZ2VyIiwidGVhbUFkbWluIiwid2ViUG9ydGFsIl19.dIrRYTl7h5uE1pezyfNzLWpd_K7mPlW7mQ5DM1sz13Q'}

  describe ".generate" do
    before(:each) do
      allow(Lightrail).to receive(:api_key).and_return(example_api_key)
    end

    it "can create a Value" do
      res = Lightrail::Values.create({
                                         id: "123-xyz",
                                         currency: "USD",
                                         balance: 10
                                     })
      puts "blah blah blah"
      puts res
    end
  end
end
