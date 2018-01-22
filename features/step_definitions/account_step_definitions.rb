# Before do
#   @contact_id = 'this-is-a-contact-id'
#   @shopper_id = 'this-is-a-shopper-id'
#   @card_id = 'this-is-a-card-id'
#   @currency = 'ABC'
#
#   @contact = {
#       'contactId' => 'this-is-a-contact-id',
#       'shopperId' => 'this-is-a-shopper-id',
#   }
#   @account_card = {
#       'contactId' => 'this-is-a-contact-id',
#       'cardId' => 'this-is-a-card-id',
#       'currency' => 'ABC',
#       'cardType' => 'ACCOUNT_CARD'
#   }
#
#   @create_account_params_with_shopper_id = {
#       shopper_id: @shopper_id,
#       currency: @currency,
#       user_supplied_id: 'this-is-a-new-account',
#   }
#
#   @create_account_params_with_contact_id = {
#       contact_id: @contact_id,
#       currency: @currency,
#       user_supplied_id: 'this-is-a-new-account',
#   }
#
#   @charge_params_with_contact_id = {
#       value: -1,
#       currency: 'ABC',
#       contact_id: @contact_id,
#   }
#
#   @charge_params_with_shopper_id = {
#       value: -1,
#       currency: 'ABC',
#       shopper_id: @shopper_id,
#   }
#
#   @fund_params_with_contact_id = {
#       value: 1,
#       currency: 'ABC',
#       contact_id: @contact_id,
#   }
#
#   @fund_params_with_shopper_id = {
#       value: 1,
#       currency: 'ABC',
#       shopper_id: @shopper_id,
#   }
# end

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


####
####
####


Given(/^method requires parameters shopperId <(.+)> and currency <(.+)> and userSuppliedId <(.+)>$/) do |shopperId, currency, userSuppliedId|
  shopper_id = shopperId
  currency = currency
  user_supplied_id = userSuppliedId

  steps %Q{
    make GET call to <contacts>
      """
      contacts?userSuppliedId=
      """
    make GET call
      """
      cards?cardType=ACCOUNT_CARD&contactId=
      """
        }
end

Then(/^make GET call to <contacts> using parameter shopperId and receive API response$/) do |responseJson|
# Then(/^make GET call to <(.+)> using parameter shopperId and receive API response$/) do |url, responseJson|
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(url + shopper_id)
              .and_return(JSON.parse(responseJson))
  contact_id = JSON.parse(responseJson)['contactId']
end

Then(/^make GET call to <cards> using parameters contactId and currency and receive API response$/) do |responseJson|
# Then(/^make GET call to <(.+)> using parameters contactId and currency and receive API response$/) do |url, responseJson|
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(url + contact_id + '&currency=' + currency)
              .and_return(JSON.parse(responseJson))
  Lightrail::Account.create({shopper_id: shopper_id, currency: currency, user_supplied_id: user_supplied_id})
end

# Then(/^make POST call to <(.+)> using parameters contactId and currency and receive API response$/) do |url, responseJson|
#
# end


####
####
####


# REQUIRES SUPPORTING VARIABLE/JSON FILE

Given(/^creating an account with parameters '(.+)', '(.+)', and '(.+)', should result in calling the following API endpoints: '(.+)' '(.+)' - receive '(.+)', then '(.+)' '(.+)' - receive '(.+)', then '(.+)' '(.+)' - receive '(.+)'$/) do |
shopperId,
    currency,
    userSuppliedId,
    method1,
    endpoint1,
    response1,
    method2,
    endpoint2,
    response2,
    method3,
    endpoint3,
    response3|

  variables = JSON.parse(File.open("features/variables.json").read)

  expect(Lightrail::Connection)
      .to receive("make_#{method1}_request_and_parse_response".to_sym)
              .with(Regexp.new(variables['endpoints'][endpoint1]))
              .and_return(variables['jsonResponses'][response1])
  expect(Lightrail::Connection)
      .to receive("make_#{method2}_request_and_parse_response".to_sym)
              .with(Regexp.new(variables['endpoints'][endpoint2]))
              .and_return(variables['jsonResponses'][response2])
  expect(Lightrail::Connection)
      .to receive("make_#{method3}_request_and_parse_response".to_sym)
              .with(Regexp.new(variables['endpoints'][endpoint3]))
              .and_return(variables['jsonResponses'][response3])

  Lightrail::Account.create({
                                shopper_id: variables[shopperId],
                                currency: variables[currency],
                                user_supplied_id: variables[userSuppliedId]
                            })

end


# Given(/creating an account with (.+) should result in calling (.+) with (.+) and corresponding (.+)/) do |parameters, httpMethods, endpoints, jsonResponses|
Given(/creating an account with/) do |table|

  variables = JSON.parse(File.open("features/variables.json").read)

  table.hashes.each do |row|

    # refactor this...
    params = row['parameters'].split(', ').map {|key| variables[key]}

    methods = row['httpMethods'].split(', ')

    endpoints = row['endpoints'].split(', ').map {|key| variables['endpoints'][key]}

    json_responses_keys = row['jsonResponses'].split(', ')
    responses = json_responses_keys.map {|key| variables['jsonResponses'][key]}


    methods.each_with_index do |method, index|
      # binding.pry
      print "INDEX #{index}: method #{method}\n"
      method == 'get' ?
          expect_to_get_endpoint_and_receive_result_with_params(endpoints[index], json_responses_keys[index], params) :
          expect_to_post_to_endpoint_and_receive_result_with_params(endpoints[index], json_responses_keys[index], params)

    end

    Lightrail::Account.create({shopper_id: params[0], currency: params[1], user_supplied_id: params[2]})

    break
  end


end


def expect_to_get_endpoint_and_receive_result_with_params(endpoint, json_response_key, params)
  variables = JSON.parse(File.open("features/variables.json").read)

  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with(Regexp.new(Regexp.escape(endpoint)))
              .and_return(variables['jsonResponses'][json_response_key])
end

def expect_to_post_to_endpoint_and_receive_result_with_params(endpoint, json_response_key, params)
  variables = JSON.parse(File.open("features/variables.json").read)

  expect(Lightrail::Connection)
      .to receive(:make_post_request_and_parse_response)
              .with(Regexp.new(Regexp.escape(endpoint)), anything)
              .and_return(variables['jsonResponses'][json_response_key])
end
