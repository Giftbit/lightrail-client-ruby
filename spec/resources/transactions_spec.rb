require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Transactions do
  subject(:factory) {Lightrail::Transactions}

  describe "Transaction Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]

    value_id = SecureRandom.uuid
    before(:all) do
      # create a value for transaction tests
      create = Lightrail::Values.create(
          {
              id: value_id,
              currency: "USD",
              balance: 1000
          })
      expect(create.body["id"]).to eq(value_id)
      expect(create.body["currency"]).to eq("USD")
      expect(create.body["balance"]).to eq(1000)
    end

    checkout_id = SecureRandom.uuid
    it "can checkout" do
      checkout = factory.checkout({
                                      id: checkout_id,
                                      currency: "USD",
                                      sources: [{
                                                    rail: "lightrail", valueId: value_id
                                                }],
                                      lineItems: [
                                          {
                                              productId: "tea pot",
                                              unitPrice: 250
                                          }
                                      ]
                                  })
      expect(checkout.status).to eq(201)
      expect(checkout.body["transactionType"]).to eq("checkout")
      expect(checkout.body["totals"]["subtotal"]).to eq(250)
      expect(checkout.body["totals"]["paidLightrail"]).to eq(250)
    end

    it "can debit" do
      debit = factory.debit({
                                id: SecureRandom.uuid,
                                currency: "USD",
                                source: {
                                    rail: "lightrail", valueId: value_id
                                },
                                amount: 50
                            })
      expect(debit.status).to eq(201)
      expect(debit.body["transactionType"]).to eq("debit")
      expect(debit.body["steps"][0]["valueId"]).to eq(value_id)
      expect(debit.body["steps"][0]["balanceChange"]).to eq(-50)
      expect(debit.body["steps"][0]["balanceAfter"]).to eq(700)
    end

    it "can credit" do
      credit = factory.credit({
                                  id: SecureRandom.uuid,
                                  currency: "USD",
                                  destination: {
                                      rail: "lightrail", valueId: value_id
                                  },
                                  amount: 1
                              })
      expect(credit.status).to eq(201)
      expect(credit.body["transactionType"]).to eq("credit")
      expect(credit.body["steps"][0]["valueId"]).to eq(value_id)
      expect(credit.body["steps"][0]["balanceChange"]).to eq(1)
      expect(credit.body["steps"][0]["balanceAfter"]).to eq(701)
    end


    it "can transfer" do
      # create value to transfer from
      value_id_to_transfer_from = SecureRandom.uuid
      create = Lightrail::Values.create(
          {
              id: value_id_to_transfer_from,
              currency: "USD",
              balance: 2
          })
      expect(create.body["id"]).to eq(value_id_to_transfer_from)
      expect(create.body["currency"]).to eq("USD")
      expect(create.body["balance"]).to eq(2)


      transfer = factory.transfer({
                                      id: SecureRandom.uuid,
                                      currency: "USD",
                                      source: {
                                          rail: "lightrail", valueId: value_id_to_transfer_from
                                      },
                                      destination: {
                                          rail: "lightrail", valueId: value_id
                                      },
                                      amount: 1
                                  })
      expect(transfer.status).to eq(201)
      expect(transfer.body["transactionType"]).to eq("transfer")

      # source
      expect(transfer.body["steps"][0]["valueId"]).to eq(value_id_to_transfer_from)
      expect(transfer.body["steps"][0]["balanceChange"]).to eq(-1)
      expect(transfer.body["steps"][0]["balanceAfter"]).to eq(1)

      # destination
      expect(transfer.body["steps"][1]["valueId"]).to eq(value_id)
      expect(transfer.body["steps"][1]["balanceChange"]).to eq(1)
      expect(transfer.body["steps"][1]["balanceAfter"]).to eq(702)
    end

    it "can reverse" do
      debit = factory.debit({
                                id: SecureRandom.uuid,
                                currency: "USD",
                                source: {
                                    rail: "lightrail", valueId: value_id
                                },
                                amount: 666
                            })
      expect(debit.status).to eq(201)
      expect(debit.body["transactionType"]).to eq("debit")
      expect(debit.body["steps"][0]["valueId"]).to eq(value_id)
      expect(debit.body["steps"][0]["balanceChange"]).to eq(-666)

      # reverse
      reverse = factory.reverse(debit.body["id"], {"id": SecureRandom.uuid})
      expect(reverse.status).to eq(201)
      expect(reverse.body["transactionType"]).to eq("reverse")
      expect(reverse.body["steps"][0]["valueId"]).to eq(value_id)
      expect(reverse.body["steps"][0]["balanceChange"]).to eq(666)
    end

    debit_to_capture_id = SecureRandom.uuid
    it "can create pending and capture" do
      pending_debit = factory.debit({
                                        id: debit_to_capture_id,
                                        currency: "USD",
                                        source: {
                                            rail: "lightrail", valueId: value_id
                                        },
                                        amount: 100,
                                        pending: true
                                    })
      expect(pending_debit.status).to eq(201)
      expect(pending_debit.body["transactionType"]).to eq("debit")
      expect(pending_debit.body["steps"][0]["valueId"]).to eq(value_id)
      expect(pending_debit.body["steps"][0]["balanceChange"]).to eq(-100)
      expect(pending_debit.body["pending"]).to eq(true)

      # capture
      capture = factory.capture_pending(pending_debit.body["id"], {"id": SecureRandom.uuid})
      expect(capture.status).to eq(201)
      expect(capture.body["transactionType"]).to eq("capture")
      expect(capture.body["steps"].length).to eq(0)
    end

    it "can create pending and void" do
      pending_debit = factory.debit({
                                        id: SecureRandom.uuid,
                                        currency: "USD",
                                        source: {
                                            rail: "lightrail", valueId: value_id
                                        },
                                        amount: 150,
                                        pending: true
                                    })
      expect(pending_debit.status).to eq(201)
      expect(pending_debit.body["transactionType"]).to eq("debit")
      expect(pending_debit.body["steps"][0]["valueId"]).to eq(value_id)
      expect(pending_debit.body["steps"][0]["balanceChange"]).to eq(-150)
      expect(pending_debit.body["pending"]).to eq(true)

      # void
      void = factory.void_pending(pending_debit.body["id"], {"id": SecureRandom.uuid})
      expect(void.status).to eq(201)
      expect(void.body["transactionType"]).to eq("void")
      expect(void.body["steps"][0]["valueId"]).to eq(value_id)
      expect(void.body["steps"][0]["balanceChange"]).to eq(150)
    end

    it "can get a transaction" do
      get = factory.get(checkout_id)
      expect(get.status).to eq(200)
      expect(get.body["id"]).to eq(checkout_id)
    end

    it "can list transactions" do
      list = factory.list({valueId: value_id, transactionType: "checkout"})
      expect(list.status).to eq(200)
      expect(list.body.length).to eq(1)
      expect(list.body[0]["id"]).to eq(checkout_id)
    end

    it "can get transaction chain" do
      chain = factory.get_transaction_chain(debit_to_capture_id)
      expect(chain.status).to eq(200)
      expect(chain.body.length).to eq(2)
      expect(chain.body[0]["transactionType"]).to be_in(["debit", "capture"])
      expect(chain.body[1]["transactionType"]).to be_in(["debit", "capture"])
      expect(chain.body[0]["id"]).to eq(debit_to_capture_id)
    end

    # Error cases and exception handling
    it "can't get with non-existent id" do
      create = factory.get("NON_EXISTENT_ID")
      expect(create.status).to eq(404)
    end

    describe "calling get with invalid id arguments" do
      it "can't get with id = {}  - throws exception" do
        expect {factory.get({})}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end

      it "can't get with id = nil - throws exception" do
        expect {factory.get(nil)}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end
    end

    it "can't get transaction chain with non-existent id" do
      create = factory.get_transaction_chain("NON_EXISTENT_ID")
      expect(create.status).to eq(404)
    end

    describe "calling get transaction chain with invalid id arguments" do
      it "can't get with id = {}  - throws exception" do
        expect {factory.get_transaction_chain({})}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end

      it "can't get transaction chain with id = nil - throws exception" do
        expect {factory.get_transaction_chain(nil)}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end
    end
  end
end
