# Lightrail Client for Ruby
Lightrail is a modern platform for digital account credits, gift cards, promotions, and points (to learn more, visit [Lightrail](https://www.lightrail.com/)). This is a basic library for developers to easily connect with the Lightrail API using Ruby. 

## Installation
This gem is available on RubyGems.org. To use it in your project, add this line to your application's Gemfile:

```ruby
gem 'lightrail_client'
```

And then execute:

```
$ bundle
```

## Usage
Before using any parts of the library, you'll need to configure it to use your API key:

```ruby
Lightrail.api_key = "<your lightrail API key>"
```

If generating shopper tokens, you'll also need to set the shared secret.

```ruby
Lightrail.shared_secret = "<your Lightrail shared secret>"
```

### Example Usage
A quick example of creating a Value.
```ruby
Lightrail::Values.create(
    {
      id: "unique-id-123",
      currency: "USD",
      balance: 10
    })
```

Full argument parameters can be found in the [Lightrail API Docs](https://lightrailapi.docs.apiary.io/#introduction). Arguments should be passed in `camelCased` exactly as they appear in the API Docs.

If you'd like to see more examples of using the gem, our full Ruby tests can be viewed [here](https://github.com/Giftbit/lightrail-client-ruby/tree/master/spec/resources).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/Giftbit/lightrail-client-ruby.

## Development
After checking out the repo, run `bin/setup` to install dependencies, then run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

You'll also need to add a .env file.
```
LIGHTRAIL_TEST_API_KEY=
```

### Publishing

Make sure to bump the version number before publishing changes. 

Run `gem build lightrail_client` to build the gem locally. The output will contain the gem name, version, and filename of the built `.gem`. 

Run `gem push {{filename}}` to publish to RubyGems. 

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
