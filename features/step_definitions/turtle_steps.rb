Given /turtles:/ do |table|
  puts table.hashes.inspect
  table.hashes.each do |row|
    step "turtle #{row[:name]} #{row[:title]}"
    # puts row
  end
end

Given /^turtle (.+) (.+)$/ do |name, title|
  puts "this turtle #{name} is the #{title}"
end

Given /two turtles/ do
  steps %{
    Given turtles:
      | name      |title     |
      | Sturm     |shortest  |
      | Liouville |tallest   |
  }
end


####
####
####
####
####
####
####


Given /^a turtle$/ do |name|
  puts "turtlenames! #{name}"
  thing = Lightrail::Connection.make_get_request_and_parse_response('thing')
  puts thing
  variables = File.open("features/variables.json").read
  puts variables

end

Given /a turtle Sturm/ do
  puts "turtlenames! strum strum strum"
  expect(Lightrail::Connection)
      .to receive(:make_get_request_and_parse_response)
              .with('thing')
              .and_return(JSON.parse('{"contactId":"here-be-contact"}'))
  puts "expecting"
end


# Given /two turtles/ do
#   steps %{
#     Given a turtle
#     And a turtle
#   }
# end


Given /two turtles '(.+)' and '(.+)'/ do |name1, name2|
  step "a turtle #{name1}"
  step "a turtle", name2
end

# Given /turtles:/ do |string|
#   puts string
# end
