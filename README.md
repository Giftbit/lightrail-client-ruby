# Lightrail Client Gem (beta)

Lightrail is a modern platform for digital account credits, gift cards, promotions, and points (to learn more, visit [Lightrail](https://www.lightrail.com/)). The Lightrail Client Gem is a basic library for developers to easily connect with the Lightrail API using Ruby. If you are looking for specific use cases or other languages, check out [related projects](#related-projects) and the complete list of all Lightrail libraries and integrations in the Integrations section of the [Lightrail API documentation](https://www.lightrail.com/docs/).

## Features

The following features are supported in this version:

- Gift Cards: charge, refund, balance-check, and fund.
- Account Credits: charge, refund, balance-check, and fund.

Note that the Lightrail API supports many other features and we are working on covering them in this gem. For the full picture of Lightrail API features check out the [Lightrail API documentation](https://www.lightrail.com/docs/).

## Usage

Before using any parts of the library, you need to set up your Lightrail API key:

```ruby
Lightrail.api_key = "<your lightrail API key>";
```

*A note on sample code snippets: for reasons of legibility, the output for most calls has been simplified. Attributes of response objects that are not relevant here have been omitted.*

## Related Projects

- [Lightrail Stripe Gem](https://github.com/Giftbit/lightrail-stripe-ruby)
- [Lightrail Java Client](https://github.com/Giftbit/lightrail-client-java)
- [Lightrail-Stripe Java Integration](https://github.com/Giftbit/lightrail-stripe-java)

### Gift Cards

A Lightrail gift card is a virtual device for issuing gift values. Each gift card has a specific `currency`, a `cardId`, and a `fullCode`, which is a unique unguessable alphanumeric string, usually released to the gift recipient in confidence. The recipient of the gift card can present the `fullCode` to redeem the gift value. For further explanation of cards and codes see the [Lightrail API documentation](https://www.lightrail.com/docs/).

#### Balance Check

You can check the balance of a gift card or code using either the `Card` class or the `Code` class: call `.get_balance_details` or `.get_total_balance` on either one, passing in the `cardId` or `fullCode` (respectively) as a parameter:

```ruby
gift_balance_details = Lightrail::Code.get_balance_details("<GIFT CODE>")
# or use the cardId:
# gift_balance_details = Lightrail::Card.get_balance_details("<GIFT CARD ID>")

#=>  {'principal' => {
            'currentValue' => 3000,
            'state' => 'ACTIVE',
            'expires' => nil,
            'startDate' => nil,
            'programId' => 'program-123456',
            'valueStoreId' => 'value-123456'
          },
		'attached' => [
          {'currentValue' => 500,
            'state' => 'ACTIVE',
            #...},
          {'currentValue' => 250,
            'state' => 'EXPIRED',
            #...}
          ],
		'currency' => 'USD',
		'cardType' => 'GIFT_CARD',
		'balanceDate' => '2017-05-29T13:37:02.756Z',
		'cardId' => 'card-123456'}

gift_total_balance = Lightrail::Card.get_total_balance("<GIFT CODE>")
#=>  3500
```

#### Charging a Gift Card

In order to make a charge, you can call `.charge` on either a `Code` or a `Card`. The minimum required parameters are the `fullCode` or `cardId`, the `currency`, and the `value` of the transaction (a negative integer in the smallest currency unit, e.g., 500 cents is 5 USD):

```ruby
gift_charge = Lightrail::Code.charge({
                                      value: -1850,
                                      currency: 'USD',
                                      code: '<GIFT CODE>'
                                    })
#=> {
       "value"=>-1850,
       "userSuppliedId"=>"2bfb5ccb",
       "transactionType"=>"DRAWDOWN",
       "currency"=>"USD",
       "transactionId"=>"transaction-8483d9",
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

## Customer Accounts

Customer Accounts are values attached to a customer and are commonly used for customer rewards and account credit programs. For further explanation of this concept check out the [Lightrail API documentation](https://www.lightrail.com/docs/).

You can interact with Customer Accounts through the `Lightrail::Contact` class. All the same functionality is offered for contact accounts as for gift cards, except that to identify a contact and transact against their account, you would pass in either a `contact_id` (generated by Lightrail) or a `shopper_id` (generated by your ecommerce store), instead of a gift card's `card_id`. Code samples follow; for more detail on how any method works, please see the gift card documentation above.

#### Account Balance Check

Call `Lightrail::Contact.get_balance_details` or `Lightrail::Contact.get_total_balance` to get detailed account balance information or a condensed total of all available value for an account.

**Note that the balance check methods require different parameters than their Gift Card counterparts:** since a single contact can have several accounts in different currencies, it is necessary to specify the account currency in a hash along with the contact identifier when performing a balance check:

```ruby
account_balance_details = Lightrail::Contact.get_balance_details({
    contact_id: '<CONTACT ID>',     # or instead of contact_id: shopper_id: '<SHOPPER ID>'
    currency: 'USD'
  })

total_available_account_balance = Lightrail::Contact.get_total_balance({
    contact_id: '<CONTACT ID>',     # or instead of contact_id: shopper_id: '<SHOPPER ID>'
    currency: 'USD'
  })
```

#### Charging and Funding and Account

You can charge or fund the account by specifying the currency and the amount:

```ruby
charge = Lightrail::Contact.charge_account({
    contact_id: '<CONTACT ID>',     # or instead use shopper_id: '<SHOPPER ID>'
    currency: 'USD',
    value: -1350
  })

fund = Lightrail::Contact.fund_account({
    contact_id: '<CONTACT ID>',     # or instead use shopper_id: '<SHOPPER ID>'
    currency: 'USD',
    value: 500
  })
```

As with gift cards, an account can also be charged by following an authorize-capture flow by adding `pending: true` to the charge params hash:

```ruby
authorize_charge = Lightrail::Contact.charge_account({
    contact_id: '<CONTACT ID>',     # or instead use shopper_id: '<SHOPPER ID>'
    currency: 'USD',
    value: -1350,
    pending: true
  })

# later on:
caputure_charge = Lightrail::Transaction.capture(authorize_charge)

# or void the transaction instead:
void_charge = Lightrail::Transaction.void(authorize_charge)
```

#### Refunding an Account Charge

You can refund an account charge the same way you would refund any other Lightrail Transaction:

```ruby
charge = Lightrail::Contact.charge_account({...})

# later on:
refund = Lightrail::Transaction.refund(charge)
```

## Installation

This gem is in alpha mode and is not yet available on RubyGems. You can use it in your project by adding this line to your application's Gemfile:

```ruby
gem 'lightrail_client', :git => 'https://github.com/Giftbit/lightrail-client-ruby.git'
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