# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "basket"
require "mocktail"
require "mock_redis"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.include Mocktail::DSL

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end

  config.after(:each) do
    Mocktail.reset
  end

  config.before(:each) do
    mock_redis = MockRedis.new
    allow(Redis).to receive(:new).and_return(mock_redis)
  end
end
