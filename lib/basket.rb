# frozen_string_literal: true

require_relative "basket/batcher"
require_relative "basket/configuration"
require_relative "basket/error"
require_relative "basket/backend_adapter/hash_backend"
require_relative "basket/backend_adapter/redis_backend"
require_relative "basket/queue_collection"
require_relative "basket/version"

module Basket
  class Error < StandardError; end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  def self.contents
    @queue_collection.data
  end

  def self.queue_collection
    @queue_collection ||= Basket::QueueCollection.new
  end

  def self.add(queue, data)
    queue_length = queue_collection.push(queue, data)
    queue_class = Object.const_get(queue)
    queue_instance = queue_class.new

    queue_instance.define_singleton_method(:element) { data }
    queue_instance.on_add

    return unless queue_length == queue_class.basket_options_hash[:size]

    queue_instance.perform
    queue_instance.on_success
  rescue => e
    raise e if e.instance_of?(Basket::Error)
    queue_instance.define_singleton_method(:error) { e }
    queue_instance.on_failure
  end

  def self.clear_all
    queue_collection.reset_backend
  end
end
