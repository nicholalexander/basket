# It would be silly to use this gem because it doesn't work yet.

[![Gem Version](https://badge.fury.io/rb/basket.svg)](https://badge.fury.io/rb/basket)
# Basket

A farmer doesn't walk down to the chicken coop, grab an egg, go back to the kitchen, go back to the coop, go back to the kitchen, etc, etc.  They take a basket with them, and as the chickens lay their eggs, they fill up the basket and when the basket is full they go make something with them!  I would make a quiche, but that's besides the case.

`Basket` lets you do just that.  Collect items until your basket is full and then, when it is, go do something with them!

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
  include Basket::Batcher
  
  basket_options length: 15

  def perform
    batch.each do | egg |
      # do some processing on each element of the batch.  In this case there will be 15 eggs.
    end

    # If you want to do something directly inline:
    Quiche.make(batch)

    # If you want to do something out of a request response cycle,
    # call out to your favorite background processing framework:
    BrunchInviteJob.perform_async
  end
 
  # There are four callbacks to the lifecycle of a basket.
  # :on_success, :on_failure, :on_add, :check_length
  # They can be used like this:
  def on_success
    let_chickens_rest
    batch.each do |egg|
      egg.inspect
    end
  end

  def on_add
    element.wash
  end
end
```

The perform method will be called after there have been 15 elements added to the batch.  The callbacks are lifecycle callbacks on the existing batch.  `on_add` gives access to a variable called `element` which is equal to the item just added to the batch.  The elements can be any kind of data, depending on the backend that you are using.  `on_add`, `on_success` and `on_failure` also give access to the whole batch through the `batch` variable.

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



## Ideas

1. Can the callbacks support ActiveSupport Notifications?
   - ActiveSupport::Callbacks extraction of callbacks
2. Batch can be postgres json blob or Redis! - Backend system
~~3. Does not execute in line~~For now.
~~4. Use ActiveJob for background execution.~~ It's up to you to handle a full basket how you want.
~~5. "Buffer", "collection", "queue"~~ Basket.
6. Default trigger is just queue length.
7. Expose basket_options trigger: :check_some_thing_lambda
8. Redis push pop.
9. Make queue ephemeral?
10. Define gotchas but don't solve them.
11. Redis fetch / Super Fetch?
12. Configuration.

https://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html


