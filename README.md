# Cpe23

Parse and serialise CPEs in CPE23, URI, and WFN formats.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cpe23'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cpe23

## Usage

Parse a CPE in CPE23, URI, or WFN format:
``` ruby
Cpe23.parse(string)
```

Serialise a CPE:
``` ruby
cpe.to_str
cpe.to_uri
cpe.to_wfn
```

Compare two CPEs:
 - all non-wildcard components must match
 - version compares the least specific of the two CPEs
 - CPEs that differ only in version are ordered by their version

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jtsymon/cpe23.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
