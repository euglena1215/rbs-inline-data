# RbsInlineData

`rbs_inline_data` gem is a tool for generating RBS files corresponding to `Data.define` in the [rbs-inline](https://github.com/soutaro/rbs-inline) syntax.
This gem is intended to be used together with [rbs-inline](https://github.com/soutaro/rbs-inline).

Here is an example of how to use it:

```rb
class User
  Address = Data.define(
    :city, #:: String
    :street, #:: String
  )
end
```

This generates the following RBS file:

```rbs
class User::Address
  extend Data::_DataClass
  attr_reader city: String
  attr_reader street: String
  def self.new: (*untyped) -> ::User::Address
              | (**untyped) -> ::User::Address
              | ...
end
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rbs_inline_data --require=false

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rbs_inline_data

## Usage

To generate RBS files, run the following command:

    # Print generated RBS files
    $ bundle exec rbs-inline-data lib

    # Save generated RBS files under sig/generated/data
    $ bundle exec rbs-inline-data lib --output


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Run `rake rbs:setup` to prepare for type checking. Since this project includes implementations using `Data.define`, you can also verify the operation of `rbs-inline-data`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/euglena1215/rbs_inline_data. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/euglena1215/rbs_inline_data/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the RbsInlineData project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/euglena1215/rbs_inline_data/blob/main/CODE_OF_CONDUCT.md).
