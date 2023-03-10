[![Gem Version](https://badge.fury.io/rb/basket.svg)](https://badge.fury.io/rb/basket)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Tests](https://github.com/nicholalexander/basket/actions/workflows/main.yml/badge.svg)](https://github.com/nicholalexander/basket/actions/workflows/main.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/dab6a6e193cbd9df2b3e/maintainability)](https://codeclimate.com/github/nicholalexander/basket/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/dab6a6e193cbd9df2b3e/test_coverage)](https://codeclimate.com/github/nicholalexander/basket/test_coverage)
# Basket

A farmer doesn't walk down to the chicken coop, grab an egg, go back to the kitchen, go back to the coop, go back to the kitchen ad infinitum.  They take a basket with them, and as the chickens lay their eggs, they fill up the basket and when the basket is full they go make something with them!  I would make a quiche, but that's besides the case.

`Basket` lets you do just that.  Collect items until your basket is full and then, when it is, go do something with them!

Basket is very new and under development.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add basket

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install basket

## Usage

Add items to your basket as they come along.  They might come along quickly, or there might be a delay between them.  Regardless, you want to collect items into your basket before going and doing something with them.

```ruby
while chicken.laying do 
  egg = { egg: {color: brown, size: medium}}
  Basket.add('QuicheBasket', egg)
end
```

The item added to the basket can be any data you want!  If you are using the in memory Queue, it is fine to store Ruby objects, but if you have a different backend, it might be better to stick to easily serializable objects.

```ruby
class QuicheBasket
  # Include the Basket::Batcher
  include Basket::Batcher

  # Define the size of your basket
  basket_options size: 15

  def perform
    batch.each do | egg |
      # Do some processing on each element of the batch.  In this case there will be 15 eggs.
    end

    # If you want to do something directly inline:
    Quiche.make(batch)

    # If you want to do something out of a request response cycle,
    # call out to your favorite background processing framework:
    BrunchInviteJob.perform_async
  end
 
  # There are four callbacks to the lifecycle of a basket.
  # :on_add, :on_success, and :on_failure.
  # They can be used like this:
  def on_success
    Farm.rest_chickens
    batch.each do |egg|
      egg.inspect
    end
  end

  def on_add
    element.wash
  end

  def on_failure
    Farm.notify_egg_monitor(error)
    raise Error
  end
end
```

The perform method will be called after there have been the defined number of elements added to the batch, specified in the `basket_options` size parameter.  The elements can be any kind of data, depending on the backend that you are using.  The default is just an in-memory hash.

The callbacks are lifecycle callbacks on the existing batch.  `on_add` gives access to a variable called `element` which is equal to the item just added to the batch. `on_add`, `on_success` and `on_failure` also give access to the whole batch through the `batch` variable.  `on_success` is called after `perform`.  

The `on_failure` use of `batch` of course may not have a full batch as the error could have been generated during `add` or `on_add`.  The `on_failure` callback also has access to an `error` variable which holds the error that was generated.  

Defining `on_add`, `on_failure`, and `on_success` is optional. 

## Configuration

In an initializer, or somewhere equally appropriate, you might put something like this:

```ruby
Basket.config do |config|
  config.redis_host = "127.0.0.2"
  config.redis_port = 6390
  config.redis_db = 10
  config.backend = :redis
end
```

The defaults for a redis backend are the standard "127.0.0.1", 6379, 15.
The default for the backend is the HashBackend, which can be set by passing `:hash` to `config.backend`, but you don't have to do that.  Because it's the default!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

This project uses Guard to facilitate local development.  You can run it with `bundle exec guard`.  It will run specs on change to files and will run `standard --fix` after passing tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/basket. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/basket/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Basket project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/basket/blob/main/CODE_OF_CONDUCT.md).



