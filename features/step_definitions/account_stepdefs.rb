When(/^a contact .*\s*exists?\s*.*: requires minimum parameters \[(.[^\]]+)\] and makes the following REST requests: \[(.[^\]]+)\](?: and throws the following error: \[(.[^\]]+)\])?$/) do |minimum_params, expectedRequestsAndResponses, errorName|

  # Consider reading this in outside of this function if more than one stepdef in this file needs it
  # Also consider breaking variables.json into feature-specific files (account_feature_variables.json, contact_feature_variables.json, etc)
  @variables = JSON.parse(File.open("features/variables.json").read)

  min_param_keys = minimum_params.split(', ')
  min_param_values = min_param_keys.map {|key| @variables[key]}
  min_params = [min_param_keys, min_param_values].transpose.to_h

  reqResKeys = expectedRequestsAndResponses.split(', ')
  reqResVals = reqResKeys.map {|key| @variables['requestResponseCombos'][key]}
  reqResCollection = [reqResKeys, reqResVals].transpose.to_h

  reqResCollection.each do |reqResKey, reqRes|
    if /error/i =~ reqResKey
      expect_to_call_endpoint_and_receive_error(reqRes['httpMethod'], reqRes['endpoint'], reqRes['response'], errorName)
    else
      expect_to_call_endpoint_and_receive_result(reqRes['httpMethod'], reqRes['endpoint'], reqRes['response'])
    end
  end

  if errorName
    expect {Lightrail::Account.create(min_params)}.to raise_error(Lightrail.const_get(errorName))
  else
    Lightrail::Account.create(min_params)
  end
end


def expect_to_call_endpoint_and_receive_result(method, endpoint, response)
  expect(Lightrail::Connection)
      .to receive("make_#{method}_request_and_parse_response".to_sym)
              .with(Regexp.new(Regexp.escape(endpoint)), any_args)
              .and_return(response)
end

def expect_to_call_endpoint_and_receive_error(method, endpoint, errorResponse, errorName)
  expect(Lightrail::Connection)
      .to receive("make_#{method}_request_and_parse_response".to_sym)
              .with(Regexp.new(Regexp.escape(endpoint)), any_args)
              .and_raise(Lightrail.const_get(errorName).new(errorResponse['message'], errorResponse))
end
