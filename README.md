# Lightrail Client Gem

Lightrail is a modern platform for digital account credits, gift cards, promotions, and points (to learn more, visit [Lightrail](https://www.lightrail.com/)). The Lightrail Client Gem is a basic library for developers to easily connect with the Lightrail API using Ruby. If you are looking for specific use cases or other languages, check out the complete list of all [Lightrail libraries and integrations](https://github.com/Giftbit/Lightrail-API-Docs/blob/master/docs/client-libraries.md).

## Features

The following features are supported in this version:

- Account Credits: create, retrieve, charge, refund, balance-check, and fund.
- Gift Cards: charge, refund, balance-check, and fund.

Note that the Lightrail API supports many other features and we are working on covering them in this gem. For a complete list of Lightrail API features check out the [Lightrail API documentation](https://www.lightrail.com/docs/).

## Related Projects

Check out the full list of [Lightrail client libraries and integrations](https://github.com/Giftbit/Lightrail-API-Docs/blob/master/docs/client-libraries.md). 

## Usage

Before using any parts of the library, you'll need to configure it to use your API key:

```ruby
Lightrail.api_key = "<your lightrail API key>"
```

*A note on sample code snippets: for reasons of legibility, the output for most calls has been simplified. Attributes of response objects that are not relevant here have been omitted.*

### Use Case: Account Credits Powered by Lightrail

For a quick demonstration of implementing account credits using this library, see our [Accounts Quickstart](https://github.com/Giftbit/Lightrail-API-Docs/blob/master/docs/quickstart/accounts.md). 


### Use Case: Gift Cards

**Looking for Lightrail's Drop-In Gift Card Solution?** 

Check out our [Drop-in Gift Card documentation](https://github.com/Giftbit/Lightrail-API-Docs/blob/master/docs/quickstart/drop-in-gift-cards.md#drop-in-gift-cards) to get started.

**Prefer to build it yourself?**

The remainder of this document is a detailed overview of the methods this library offers for managing Gift Cards. It assumes familiarity with the concepts in our [Gift Card guide](https://github.com/Giftbit/Lightrail-API-Docs/blob/master/use-cases/gift-card.md).

#### Balance Check

There are several ways to check the balance of a gift card or code. Because you can attach conditional value to a card/code (for example, "get $5 off when you buy a red hat"), the available balance can vary depending on the transaction context.

##### Maximum Value

To get the maximum value of a card/code, i.e. the sum of all active value stores, call either `Card.get_maximum_value(<CARD ID>)` or `Code.get_maximum_value(<CODE>)`. This method will return an integer which represents the sum of all active value stores in the smallest currency unit (e.g. cents):

```ruby
maximum_gift_value = Lightrail::Card.get_maximum_value("<GIFT CARD ID>")
# or use the code:
# maximum_gift_value = Lightrail::Code.get_maximum_value("<GIFT CODE>")

#=>  3500
```

##### Card/Code Details

If you would like to see a breakdown of how the value is stored on a card or code you can use the `.get_details` method. This will return a breakdown of all attached value stores, along with other important information:

```
gift_details = Lightrail::Card.get_details("<GIFT CARD ID>")
# or use the code:
# gift_details = Lightrail::Code.get_details("<GIFT CODE>")

#=> {
        "valueStores": [
            {
                "valueStoreType": "PRINCIPAL",
                "value": 483,
                "state": "ACTIVE",
                "expires": null,
                "startDate": null,
                "programId": "program-123456",
                "valueStoreId": "value-11111111",
                "restrictions": []
            },
            {
                "valueStoreType": "ATTACHED",
                "value": 1234,
                "state": "ACTIVE",
                "expires": "2017-11-13T19:29:31.613Z",
                "startDate": null,
                "programId": "program-7890",
                "valueStoreId": "value-2222222",
                "restrictions": ["Valid for purchase of a red hat"]
            },
            {
                "valueStoreType": "ATTACHED",
                "value": 500,
                "state": "EXPIRED",
                "expires": "2017-09-13T19:29:37.464Z",
                "startDate": null,
                "programId": "program-24680",
                "valueStoreId": "value-3333333",
                "restrictions": ["Cart must have five or more items"]
            }
        ],
        "currency": "USD",
        "cardType": "GIFT_CARD",
        "asAtDate": "2017-11-06T19:29:41.533Z",
        "cardId": "card-12q4wresdgf6ey",
        "codeLastFour": "WXYZ"
    }
}
```

These details can be useful for showing a customer a summary of their gift balance, or for incentivizing further spending (e.g. "Add a red hat to your order to get $12.34 off").

##### Simulate Transaction

If you would like to know how much is available for a specific transaction, use the `.simulate_charge` method. Simply pass in all the same parameters as you would to make a regular charge (see below) **including metadata** so that the Lightrail engine can assess whether necessary conditions are met for any attached value. 

The `value` of the response will indicate the maximum amount that can be charged given the context of the transaction, which can be useful when presenting your customer with a confirmation dialogue. The `value` is a drawdown amount and will therefore be negative:

```ruby
simulated_charge = Lightrail::Card.simulate_charge({
                                      value: -1850,
                                      currency: 'USD',
                                      card_id: '<GIFT CARD ID>',
                                      metadata: {cart: {items_total: 5}},
                                    })
#=> {
       "value"=>-1550,
       "userSuppliedId"=>"2bfb5ccb",
       "transactionType"=>"DRAWDOWN",
       "currency"=>"USD",
       "transactionBreakdown": [
            {
                "value": -1234,
                "valueAvailableAfterTransaction": 0,
                "valueStoreId": "value-4f9a362e7206445796d934727e0d2b27"
            },
            {
                "value": -616,
                "valueAvailableAfterTransaction": 0,
                "valueStoreId": "value-9850b36634b541f5bc6fd280b0198b3d",
                "restrictions": ["Cart must have five or more items"],
            }
         ],
       "transactionId": null,
       "dateCreated": null,
       #...
    }
```

Note that because this is a simulated transaction and not a real transaction, the `transactionId` and `dateCreated` will both be `null`.

#### Charging a Gift Card

In order to make a charge, you can call `.charge` on either a `Code` or a `Card`. The minimum required parameters are the `fullCode` or `cardId`, the `currency`, and the `value` of the transaction (a negative integer in the smallest currency unit, e.g., 500 cents is 5 USD):

```ruby
gift_charge = Lightrail::Code.charge({
                                      value: -2500,
                                      currency: 'USD',
                                      code: '<GIFT CODE>'
                                    })
#=> {
       "value"=>-1850,
       "userSuppliedId"=>"2bfb5ccb",
       "transactionType"=>"DRAWDOWN",
       "currency"=>"USD",
       #...
    }
```

**A note on idempotency:** All calls to create or act on transactions (refund, void, capture) can optionally take a `userSuppliedId` parameter. The `userSuppliedId` is a client-side identifier (unique string) which is used to ensure idempotency (for more details, see the  [API documentation](https://www.lightrail.com/docs/)). If you do not provide a `userSuppliedId`, the gem will create one for you for any calls that require one.

```ruby
gift_charge = Lightrail::Code.charge({
                                      value: -1850,
                                      currency: 'USD',
                                      code: '<GIFT CODE>',
                                      userSuppliedId: 'order-13jg9s0era9023-u9a-0ea'
                                    })
```

Note that Lightrail does not support currency exchange and the currency provided to these methods must match the currency of the gift card.

For more details on the parameters that you can pass in for a charge request and the response that you will get back, see the [API documentation](https://www.lightrail.com/docs/).

#### Authorize-Capture Flow

By adding ` pending: true` to your charge param hash when calling either `Card.charge` or `Code.charge`, you can create a pre-authorized pending transaction. When you are ready to capture or void it, you will call `Transaction.capture` or `Transaction.void` and pass in the response you get back from the call to create the pending charge:

```ruby
gift_charge = Lightrail::Code.charge({
                                      value: -1850,
                                      currency: 'USD',
                                      code: '<GIFT CODE>',
                                      pending: true,
                                    })
# later on
Lightrail::Transaction.capture(gift_charge)
#=> {
       "value"=>-1850,
       "userSuppliedId"=>"12c2d18f",
       "dateCreated"=>"2017-05-29T13:37:02.756Z",
       "transactionType"=>"DRAWDOWN",
       "transactionAccessMethod"=>"RAWCODE",
       "cardId"=>"<GIFT CARD ID>",
       "currency"=>"USD",
       "transactionId"=>"transaction-8483d9",
       "parentTransactionId"=>"transaction-cf353236"
    }

# or
Lightrail::Transaction.void(gift_charge)
#=> {
       "value"=>-1850,
       "userSuppliedId"=>"12c2d18f",
       "dateCreated"=>"2017-05-29T13:37:02.756Z",
       "transactionType"=>"PENDING_VOID",
       "transactionAccessMethod"=>"RAWCODE",
       "cardId"=>"<GIFT CARD ID>",
       "currency"=>"USD",
       "transactionId"=>"transaction-d10e76",
       "parentTransactionId"=>"transaction-cf353236"
    }
```

Note that `Transaction.void` and `Transaction.capture` will each return a **new transaction** and will not modify the original pending transaction they are called on. These new transactions will have their own `transactionId`. If you need to record the transaction ID of the captured or canceled charge, you can get it from the hash returned by these methods.

#### Refunding a Charge

You can undo a charge by calling `Transaction.refund` and passing in the details of the transaction you wish to refund. This will create a new `refund` transaction which will return the charged amount back to the card. If you need the transaction ID of the refund transaction, you can find it in the response from the API.

```ruby
gift_charge = Lightrail::Code.charge(<CHARGE PARAMS>)

# later on
Lightrail::Transaction.refund(gift_charge)
#=> {
       "value"=>1850,
       "userSuppliedId"=>"873b08ab",
       "dateCreated"=>"2017-05-29T13:37:02.756Z",
       "transactionType"=>"DRAWDOWN_REFUND",
       "transactionAccessMethod"=>"CARDID",
       "cardId"=>"<GIFT CARD ID>",
       "currency"=>"USD",
       "transactionId"=>"transaction-0f2a67",
       "parentTransactionId"=>"transaction-2271e3"
    }
```

Note that this does not necessarily mean that the refunded amount is available for a re-charge. In the edge case where the funds for the original charge came from a promotion which has now expired, refunding will return those funds back to the now-expired value store and therefore the value will not be available for re-charge. To learn more about using value stores for temporary promotions, see the [Lightrail API docs](https://github.com/Giftbit/Lightrail-API-Docs/blob/master/use-cases/promotions.md).

#### Funding a Gift Card

To fund a gift card, you can call `Card.fund`. Note that the Lightrail API does not permit funding a gift card by its `code` and the only way to fund a card is by providing its `cardId`:

```ruby
gift_fund = Lightrail::Card.fund({
                                      value: 500,
                                      currency: 'USD',
                                      card_id: '<GIFT CARD ID>',
                                    })
#=> {
       "value"=>500,
       "userSuppliedId"=>"7676c986",
       "dateCreated"=>"2017-05-29T13:37:02.756Z",
       "transactionType"=>"FUND",
       "transactionAccessMethod"=>"CARDID",
       "cardId"=>"<GIFT CARD ID>",
       "currency"=>"USD",
       "transactionId"=>"transaction-dee3ee7"
    }
```


## Installation

This gem is available on RubyGems.org. To use it in your project, add this line to your application's Gemfile:

```ruby
gem 'lightrail_client'
```

And then execute:

```
$ bundle
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Giftbit/lightrail-client-ruby.

## Development

After checking out the repo, run `bin/setup` to install dependencies, then run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).