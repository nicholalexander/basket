# Basket

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/basket`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

You have something you need to do, like make an API call.  Don't call the API, add it to a batch!

```ruby
body = { data: "bloop" }
Basket.add('SomeApi', body)
```



The body can be any data you want, not nessecarily a json blob that the external API is expecting.

Then `rails g batch`

```ruby
class SomeApi
  include Basket::Batcher
  
  basket_options length: 15

  def perform
    batch.each do | element |
        # do some processing on each element of the batch.  In this case there will be 15 objects with the key `data`.
    end

    # send the batch off to some API Client
    CatClient.get(batch)
    CatWorker.perform_async(blablabla)
  end
 
  # callbacks
  :on_success, :on_failure, :on_add, :check_length

  on_success: :bloop

  def bloop
    Rails.logger("Yay!")
  end
end
```

The perform method will be called after there have been 15 elements added to the batch.  The callbacks are lifecycle callbacks on the existing of the batch.  `on_add` takes an argument of the element that is being added.  The elements are just a hash.  `on_success` and `on_failure` give access to the whole batch.

```ruby
Configuration do |config|
  # config.element_retention: 500_000
  config.queue: 'default'
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/basket. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/basket/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Basket project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/basket/blob/main/CODE_OF_CONDUCT.md).



## Ideas

1. Can the callbacks support ActiveSupport Notifications?
   - ActiveSupport::Callbacks extraction of callbacks
2. Batch can be postgres json blob or Redis!
3. Does not execute in line
4. Use ActiveJob for background execution.
5. "Buffer", "collection", "queue"
6. Default trigger is just queue length.
7. Expose basket_options trigger: :check_some_thing_lambda
8. Redis push pop.
9. Make queue ephemeral?
10. Define gotchas but don't solve them.
11. Redis fetch / Super Fetch?

https://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html


