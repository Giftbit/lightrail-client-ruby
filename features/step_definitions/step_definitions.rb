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

  @create_account_params_with_shopper_id = {
      shopper_id: @shopper_id,
      currency: @currency,
      user_supplied_id: 'this-is-a-new-account',
  }

  @create_account_params_with_contact_id = {
      contact_id: @contact_id,
      currency: @currency,
      user_supplied_id: 'this-is-a-new-account',
  }

  @charge_params_with_contact_id = {
      value: -1,
      currency: 'ABC',
      contact_id: @contact_id,
  }

  @charge_params_with_shopper_id = {
      value: -1,
      currency: 'ABC',
      shopper_id: @shopper_id,
  }

  @fund_params_with_contact_id = {
      value: 1,
      currency: 'ABC',
      contact_id: @contact_id,
  }

  @fund_params_with_shopper_id = {
      value: 1,
      currency: 'ABC',
      shopper_id: @shopper_id,
  }
end

# POC EXAMPLE
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

Then(/handles json/) do |json|
  happy_response = Faraday::Response.new(status: 200, body: json)
  handled_response = Lightrail::Connection.handle_response(happy_response)
  expect(handled_response).to have_key('transaction'), "expected to have key 'transaction', got #{handled_response}"
end


####
####
####

Then(/creates a new account given a shopperId '(.+)' & currency '(.+)'/) do |shopperId, currency|
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(/contacts\?userSuppliedId=#{shopperId}/)
              .and_return({"contacts" => [{"contactId" => @contact_id}]})
  expect(Lightrail::Connection)
      .to receive(:make_post_request_and_parse_response)
              .with(/cards/, hash_including(:cardType => 'ACCOUNT_CARD', :contactId => @contact_id, :userSuppliedId => 'this-is-a-new-account'))
              .and_return({"card" => {}})
  Lightrail::Account.create(@create_account_params_with_shopper_id)
end

Then(/creates a new account given a contactId '(.+)' & currency '(.+)/) do |contactId, currency|
  expect(Lightrail::Connection)
      .to receive(:make_post_request_and_parse_response)
              .with(/cards/, hash_including(:cardType => 'ACCOUNT_CARD', :contactId => contactId, :userSuppliedId => 'this-is-a-new-account'))
              .and_return({"card" => {}})
  Lightrail::Account.create(@create_account_params_with_contact_id)
end

Then(/throws an error if no contactId or shopperId/) do
  expect {Lightrail::Account.create({currency: 'ABC', userSuppliedId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)
end

Then(/throws an error if no currency/) do
  expect {Lightrail::Account.create({contactId: 'ABC', userSuppliedId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)
end

Then(/throws an error if no userSuppliedId/) do
  expect {Lightrail::Account.create({currency: 'ABC', shopperId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)
end
