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
### Adding

Add items to your basket as they come along.  They might come along quickly, or there might be a delay between them.  Regardless, you want to collect items into your basket before going and doing something with them.

```ruby
while chicken.laying? do 
  egg = { egg: {color: brown, size: medium}}
  Basket.add('QuicheBasket', egg)
end
```

The item added to the basket can be any data you want!  If you are using the in memory Queue, it is fine to store Ruby objects, but if you have a different backend, must be JSON serializable via `to_json`.

### Your basket

When a basket has become full after you have added a bunch of things to it, it performs actions!  See below for the full definition of a basket.

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
 
  # There are three callbacks to the lifecycle of a basket.
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

### Search

You may search through your basket, if for example, you need to see if you've accidentally collected a robin egg and not a chicken egg!

```ruby
search_results = Basket.search("QuicheBasket") do |egg|
  egg.color == "blue"
end
```

The block you pass will match against the objects in your basket.  If you have ruby objects in your basket, you can match against their properties just as if you were accessing them one at a time.  If you have json objects in your basket, you will be searching through a hash thusly:

```ruby
search_results = Basket.search("PlaylistBasket") do |song|
  song[:artist] == "Vansire"
end
```

The search results will be a fully qualified basket element which will contain an id attribute and a data attribute.  In the case of using the MemoryBackend, you might see something like this:

```ruby
# ...continued from above
search_results.first  #=> #<Basket::Element:0x00000001075d9c80
                      #   @data=#<Egg color="blue", size="smol">
                      #   @id="5fe3df9e-4063-4b67-a08f-e36b847087c7">
```

You'll note that the result of a search is an array of basket elements.  An element consists of the data that you put in and ID.  What is the id for?  Glad you asked.

### Remove

You can also remove something from your basket.  Perhaps it is deleted in the database and no longer contains a valid reference to data?  Perhaps you found that robin egg and don't actually want to use it to make a quiche, because who would?  Either way, removing the element is easy!

```ruby
# ...continued from above
element_id_to_remove = search_results.first
removed_egg = Basket.remove('Quiche', element_id_to_remove)
removed_egg #=> #<Egg color="blue", size="smol">
```

Voila!

### A Note of Warning

Searching for and removing elements from your basket is an inherently tricky process as your basket may fill up and execute the `perform` action while searching and removing.
## Configuration

In an initializer, or somewhere equally appropriate, you might put something like this:

```ruby
Basket.configure do |config|
  config.redis_host = "127.0.0.2"
  config.redis_port = 6390
  config.redis_db = 10
  config.backend = :redis
  config.namespace = :basket
end
```

The defaults for a redis backend are the standard `"127.0.0.1"`, `6379`, `15` with a namespace of `:basket`.

The default for the backend is the MemoryBackend, which can be set by passing `:memory` to `config.backend`, but you don't have to do that.  Because it's the default!

For the redis configuration, you can alternatively pass a url, thusly:

```ruby
Basket.configure do |config|
  config.backend = :redis
  config.redis_url = "redis://:p4ssw0rd@10.0.1.1:6380/15"
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

This project uses Guard to facilitate local development.  You can run it with `bundle exec guard`.  It will run specs on change to files and will run `standard --fix` after passing tests.

Looking through the code base, the majority of the work happens in [lib/basket/handle_add.rb](https://github.com/nicholalexander/basket/blob/main/lib/basket/handle_add.rb).  Alternatively, you might be interested in the [backend adapters](https://github.com/nicholalexander/basket/tree/main/lib/basket/backend_adapter) for how the gem works with in memory hashes and/or a redis backend.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nicholalexander/basket. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nicholalexander/basket/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Basket project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nicholalexander/basket/blob/main/CODE_OF_CONDUCT.md).



