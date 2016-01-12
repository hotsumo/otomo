# Otomo

Welcome to Otomo, the simple HTTP robot !

This gem provide some tools to request http server and process the answer.
This gem is useful if:

- You need middle level abstraction for querying others servers.

For example, Otomo manage cookie and session, handle xml/html using `nokogiri` and `json`

Actually, I wasn't very happy with other gems I tried. Net/http is a bit too low level to make things clear easily when you use sessions, and some HTTP robots was way too specialized/high-level for me.

Here comes the man in the middle !

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'otomo', github: "hotsumo/otomo"
```

And then execute:

    $ bundle

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

Because this will erase your scope (self will be the DSL), if you want to continue to have the current scope,
you can instead use the parametered version of the DSL:

```ruby
  Otomo.session "http://myhost.tld" do |otomo|
    document = otomo.get "/"

    post_data = {}
    document.css("form input").each do |input|
      post_data[input["name"]] = input["value"]
    end

    otomo.post "/sign-in", post_data
  end
```

## Advantages over net/http

- Transparent management of sessions and cookie
- Transparent management of redirections
- Raise Otomo::BadResponse if any error (not a 400 response code)
- Cool DSL look
- You still have a low-level access to `net/http` through `otomo.http` in the DSL.

## Usage of the DSL

Once in the loop, you can call:

* `otomo`
Access to the robot (see the source of `robot.rb` for more information)

* `debug_mode!`
Enable debug mode of net/http, to see what's in and out !

- `raw_mode!`
Set the robot to raw mode. All return of `get`, `post` etc. will be a net/http response (no processing with nokogiri or Json.parse)

* `get|post|put|delete(path, data={})`
Do a *insert method here* request !

* request(method, path, data={})
Do the wanted method.

* `header`
Access to the headers of the next HTTP request. You can set-up the headers into the `Otomo.session` call (see example)

* `add_cookie(name, value)`
Add a cookie manually

* `remove_cookie(name)`
Remove a cookie manually

- `clear_cookies`
Clear all the cookies.

## Handling the MIME types

You can create your own handler for each Content-Type you want.
Currently there's handler for html, json, xml and a "text" default handler.

Example with the HtmlHandler:

```ruby
  require 'nokogiri'
  module Otomo
    module Handlers
      class HtmlHandler
        def process resp
          Nokogiri::HTML(resp.body)
        end
      end
    end
  end

  Otomo::FormatHandlers["text/html"] = Otomo::Handlers::HtmlHandler.new
```

Feel free to create or overwrite the handlers !

If you need more low level access to the answer of the server, you can use `raw_mode!` before any requests.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hotsumo/otomo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

