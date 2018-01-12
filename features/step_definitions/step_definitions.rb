Before do
  @contact_id = 'this-is-a-contact-id'
  @shopper_id = 'this-is-a-shopper-id'
  @card_id = 'this-is-a-card-id'
  @currency = 'ABC'

  @contact = {
      'contactId' => 'this-is-a-contact-id',
      'shopperId' => 'this-is-a-shopper-id',
  }
  @account_card = {
      'contactId' => 'this-is-a-contact-id',
      'cardId' => 'this-is-a-card-id',
      'currency' => 'ABC',
      'cardType' => 'ACCOUNT_CARD'
  }
end


Given("a Contact exists, no account in given currency") do
end

When("I pass in a shopperId, currency & userSuppliedId") do
end

Then("create a new Account") do
  account = Lightrail::Account.create({shopper_id: @shopper_id, currency: @currency, user_supplied_id: @userSuppliedId})
  expect(account['cardType']).to eq('ACCOUNT_CARD')
end


####

Given("a Contact with an Account in given currency") do
end

Then("return the existing Account") do
  account = Lightrail::Account.create({shopper_id: @shopper_id, currency: @currency, user_supplied_id: @userSuppliedId})
  expect(account['cardType']).to eq('ACCOUNT_CARD')
end


####

Given("a Contact with an Account in a given currency") do
end

When("I retrieve the Contact's Account card for that currency") do
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{@contact_id}\&currency=#{@currency}/)
              .and_return({"cards" => [@account_card]})

  @account = Lightrail::Account.retrieve({contactId: @contact['contactId'], currency: @account_card['currency']})

  expect(@account['cardId']).to eq('this-is-a-card-id')
end

####

Then("return the Account card") do
end

####

Then("error handling for .create") do
  expect {Lightrail::Account.create({currency: 'ABC', userSuppliedId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)

  expect {Lightrail::Account.create({contactId: 'ABC', userSuppliedId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)

  expect {Lightrail::Account.create({currency: 'ABC', shopperId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)
end

####

Then("retrieve account card by shopperId and currency") do
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(/contacts\?userSuppliedId=#{@shopper_id}/)
              .and_return({"contacts" => [{"contactId" => @contact_id}]})
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{@contact_id}\&currency=#{@currency}/)
              .and_return({"cards" => [{"contactId" => @contact_id, "cardId" => @card_id}]})
  Lightrail::Account.retrieve(shopper_id: 'shop', currency: @currency)
end

####

# Then("I can create an account with shopperId '(.)' and currency '(.)' and userSuppliedId '(.)'") do |shopper_id, currency, user_supplied_id|
Then(/I can create an account with shopperId '(.+)' and currency '(.+)' and userSuppliedId '(.+)'/) do |shopper_id, currency, user_supplied_id|
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(/contacts\?userSuppliedId=#{shopper_id}/)
              .and_return({"contacts" => [{"contactId" => @contact_id}]})
  expect(Lightrail::Connection)
      .to receive(:make_post_request_and_parse_response)
              .with(/cards/, hash_including(:cardType => 'ACCOUNT_CARD', :contactId => @contact_id, :userSuppliedId => user_supplied_id))
              .and_return({"card" => {}})
  Lightrail::Account.create({shopper_id: shopper_id, currency: currency, user_supplied_id: user_supplied_id})

end