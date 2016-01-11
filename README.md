# Otomo

Welcome to Otomo, the simple HTTP robot !

This gem provide some tools to request http server and process the answer.
This gem is useful if:

- You need middle level abstraction for querying others servers.

For example, Otomo manage cookie and session, handle xml/html using `nokogiri` and `json`

Actually, I wasn't very happy with what I tried. Net/http is a bit too low level to make things clear easily when you use session, and some HTTP robots was way to specialized/high-level for me. 

Here comes the man in the middle !

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'otomo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install otomo

## Usage

Starting a browsing party !


```ruby
  Otomo.session "http://myhost.tld" do
    document = get "/"

    post_data = {}
    document.css("form input").each do |input|
      post_data[input["name"]] = input["value"]
    end

    post "/sign-in", post_data

  end
```

## Advantages over Net/http

- Manage sessions and cookie
- Manage redirections
- Raise Otomo::BadResponse if error
- Cool DSL writing
- You still have a low-level access to `net/http` through `otomo.http` in the DSL.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hotsumo/otomo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

