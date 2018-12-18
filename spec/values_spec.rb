require "spec_helper"
require 'securerandom'

RSpec.describe Lightrail::Values do
  subject(:factory) {Lightrail::Values}

  # todo - need to sort out where this API key goes.
  let(:example_api_key) {'eyJ2ZXIiOjMsInZhdiI6MSwiYWxnIjoiSFMyNTYiLCJ0eXAiOiJKV1QifQ.eyJnIjp7Imd1aSI6InVzZXItOGM5OTlmODlhMzg3NGU0Mzg2M2QxYjAzN2IzNDU5ZDktVEVTVCIsImdtaSI6InVzZXItOGM5OTlmODlhMzg3NGU0Mzg2M2QxYjAzN2IzNDU5ZDktVEVTVCIsInRtaSI6InVzZXItOGM5OTlmODlhMzg3NGU0Mzg2M2QxYjAzN2IzNDU5ZDktVEVTVCJ9LCJhdWQiOiJBUElfS0VZIiwiaXNzIjoiU0VSVklDRVNfVjEiLCJpYXQiOjE1MzMyMzIyNjQuMDQ0LCJqdGkiOiJiYWRnZS1iNmZhNWQxNTQ4MjU0Y2M0OTM2MjMyZDEwMjY5NWJiMiIsInBhcmVudEp0aSI6ImJhZGdlLTlmNDZiMTZiNjJjODRlY2NiZmFmMjY5ZmI5ZmI3NmIyIiwic2NvcGVzIjpbXSwicm9sZXMiOlsiYWNjb3VudE1hbmFnZXIiLCJjb250YWN0TWFuYWdlciIsImN1c3RvbWVyU2VydmljZU1hbmFnZXIiLCJjdXN0b21lclNlcnZpY2VSZXByZXNlbnRhdGl2ZSIsInBvaW50T2ZTYWxlIiwicHJvZ3JhbU1hbmFnZXIiLCJwcm9tb3RlciIsInJlcG9ydGVyIiwic2VjdXJpdHlNYW5hZ2VyIiwidGVhbUFkbWluIiwid2ViUG9ydGFsIl19.dIrRYTl7h5uE1pezyfNzLWpd_K7mPlW7mQ5DM1sz13Q'}

  describe ".generate" do
    before(:each) do
      allow(Lightrail).to receive(:api_key).and_return(example_api_key)
    end

    value_id = SecureRandom.uuid
    full_code = SecureRandom.alphanumeric.to_s
    last4 = full_code.split(//).last(4).join("").to_s
    it "can create a Value" do
      response = Lightrail::Values.create({
                                              id: value_id,
                                              currency: "USD",
                                              balance: 10,
                                              code: full_code
                                          })
      expect(response["id"]).to eq(value_id)
      expect(response["currency"]).to eq("USD")
      expect(response["balance"]).to eq(10)
      expect(response["code"]).to eq("…#{last4}")
    end

    it "can't create a Value without an id - test basic error handling" do
      expect {Lightrail::Values.create({
                                           currency: "USD",
                                       })
      }.to raise_error do |error|
        expect(error).to be_a(Lightrail::LightrailError)
        expect(error.status).to eq(422)
        expect(error.message).to_not be_nil
      end
    end

    it "can get Value" do
      response = Lightrail::Values.get(value_id, {
          id: value_id,
          currency: "USD",
          balance: 10
      })
      expect(response["id"]).to eq(value_id)
      expect(response["currency"]).to eq("USD")
      expect(response["balance"]).to eq(10)
      expect(response["code"]).to eq("…#{last4}")
    end

    it "can get Value and view fullcode" do
      response = Lightrail::Values.get(value_id, {showCode: true})
      expect(response["id"]).to eq(value_id)
      expect(response["currency"]).to eq("USD")
      expect(response["balance"]).to eq(10)
      expect(response["code"]).to eq(full_code)
    end
  end
end
