Before do
  @example_api_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJnIjp7Imd1aSI6Imdvb2V5IiwiZ21pIjoiZ2VybWllIn19.XxOjDsluAw5_hdf5scrLk0UBn8VlhT-3zf5ZeIkEld8'
  @example_shared_secret = 'secret'
  @example_shopper_id = 'this-is-a-shopper-id'
  @example_contact_id = 'this-is-a-contact-id'
  @example_user_supplied_id = 'this-is-a-user-supplied-id'

  allow(Lightrail).to receive(:api_key).and_return(@example_api_key)
  allow(Lightrail).to receive(:shared_secret).and_return(@example_shared_secret)
end

Then(/generates a JWT with the supplied shopper_id '(.+)'/) do |shopperId|
  token = Lightrail::ShopperTokenFactory.generate({shopper_id: shopperId})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})
  expect(decoded[0]['g']['shi']).to eq(shopperId)
end

Then(/generates a JWT with the supplied contact_id '(.+)'/) do |contactId|
  token = Lightrail::ShopperTokenFactory.generate({contact_id: contactId})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})
  expect(decoded[0]['g']['coi']).to eq(contactId)
end

Then(/generates a JWT with the supplied contact user_supplied_id '(.+)'/) do |userSuppliedId|
  token = Lightrail::ShopperTokenFactory.generate({user_supplied_id: userSuppliedId})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})

  expect(decoded[0]['g']['cui']).to eq(userSuppliedId)
end

Then(/correctly applies the specified validity period '(.+)'/) do |validity_period|
  token = Lightrail::ShopperTokenFactory.generate({shopper_id: @example_shopper_id}, validity_period.to_i)
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})
  expect(decoded[0]['exp']).to eq(decoded[0]['iat'] + validity_period.to_i)
end

Then(/includes 'iat'/) do
  token = Lightrail::ShopperTokenFactory.generate({shopper_id: @example_shopper_id})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})
  expect(decoded[0]['iat']).to be_a(Integer)
end

Then(/includes 'iss: MERCHANT'/) do
  token = Lightrail::ShopperTokenFactory.generate({shopper_id: @example_shopper_id})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})
  expect(decoded[0]['iss']).to eq("MERCHANT")
end


Given(/an API key such as '(.+)'/) do |api_key|
end

And(/a shared secret such as '(.+)'/) do |secret|
end

# When(/generate a shopperToken with contact identifier type <(.+)> and identifer <(.+)> and validity period <(.+)>/) do |contactIdentifierType, contactIdentifierValue, validityPeriod|
#   @token = Lightrail::ShopperTokenFactory.generate({contactIdentifierType => contactIdentifierValue}, validityPeriod)
# end
#
# Then(/the contact identifier should be <(.+)> and the validity period should be <(.+)>/) do |decodedContactIdentifier, validityPeriod|
#   @decoded = JWT.decode(@token, @example_shared_secret, true, {algorithm: 'HS256'})
#   # expect(@decoded)
# end
#
# And(/the token should include 'iss: MERCHANT'/) do
#
# end


#####

When(/I generate a shopper token the decoded token should include \/(.+)\//) do |thingToInclude|
  token = Lightrail::ShopperTokenFactory.generate({shopper_id: @example_shopper_id})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})

  expect(JSON.generate(decoded)).to include_json(thingToInclude)
end

When(/I generate a shopper token with shopperId '(.+)', the decoded token should include/) do |shopperId, tokenBody|
# When(/generate a shopper token with shopperId '(.+)', the decoded token should include: """(.+)""" and also """(.+)""" and also """(.+)"""/) do |shopperId, tokenBody, iss, alg|

  token = Lightrail::ShopperTokenFactory.generate({shopper_id: shopperId})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})

  expect(JSON.generate(decoded[0])).to include_json(tokenBody)
end

When(/I generate a shopper token with contactId '(.+)', the decoded token should include/) do |contactId, tokenBody|
  token = Lightrail::ShopperTokenFactory.generate({contact_id: contactId})
  decoded = JWT.decode(token, @example_shared_secret, true, {algorithm: 'HS256'})

  expect(JSON.generate(decoded[0])).to include_json(tokenBody)
end


##########

When(/I generate a shopperToken with contact identifier type '(.+)' and identifer '(.+)' and validity period '(.+)'/) do |contactIdentifierType, contactIdentifierValue, validityPeriod|
  # @contactIdentifierType = contactIdentifierType
  # @contactIdentifierValue = contactIdentifierValue
  # @validityPeriod = validityPeriod
  binding.pry
  @token = Lightrail::ShopperTokenFactory.generate({:"#{contactIdentifierType}" => contactIdentifierValue}, validityPeriod)
end

Then(/the contact identifier of type '(.+)' should be '(.+)' and the validity period should be '(.+)'/) do |decodedType, decodedContactIdentifier, validity|
  decoded = JWT.decode(@token, @example_shared_secret, true, {algorithm: 'HS256'})
  expect(decoded[0][decodedType]).to eq(decodedContactIdentifier)
  # expect(decoded[0][decodedType]).to eq(decodedContactIdentifier)
end

