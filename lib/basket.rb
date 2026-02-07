# frozen_string_literal: true

require_relative "basket/error"
require_relative "basket/backend_adapter"
require_relative "basket/backend_adapter/memory_backend"
require_relative "basket/backend_adapter/redis_backend"
require_relative "basket/batcher"
require_relative "basket/configuration"
require_relative "basket/element"
require_relative "basket/handle_add"
require_relative "basket/queue_collection"
require_relative "basket/version"

require "json"
require "monitor"

# Basket is a batching library that accumulates items and acts on them
# when a configured threshold is reached.
module Basket
  @monitor = Monitor.new

  # Returns the global configuration instance.
  # @return [Basket::Configuration]
  def self.config
    @monitor.synchronize { @config ||= Configuration.new }
  end

  # Yields the global configuration for modification.
  # @yield [config] the configuration instance
  # @yieldparam config [Basket::Configuration]
  # @example
  #   Basket.configure do |config|
  #     config.backend = :redis
  #     config.redis_url = "redis://localhost:6379/0"
  #   end
  def self.configure
    yield(config)
  end

  # Returns all queue data as a hash of queue names to arrays of Elements.
  # @return [Hash{String => Array<Basket::Element>}]
  def self.contents
    queue_collection.data
  end

  # Returns the data for a single queue.
  # Routes to the correct backend when the queue class has a per-class backend configured.
  # @param queue [String] the queue name (must match a defined Batcher class)
  # @return [Array] the data values stored in the queue
  # @raise [Basket::BasketNotFoundError] if the queue class is not defined
  def self.peek(queue)
    queue_collection_for_queue(queue).read(queue)
  end

  # Returns the global queue collection instance.
  # @return [Basket::QueueCollection]
  def self.queue_collection
    @monitor.synchronize { @queue_collection ||= Basket::QueueCollection.new }
  end

  # Returns a cached queue collection for a specific backend class.
  # @param backend_class [Class] the backend adapter class
  # @return [Basket::QueueCollection]
  def self.queue_collection_for(backend_class)
    @monitor.synchronize do
      @backend_queue_collections ||= {}
      @backend_queue_collections[backend_class] ||= Basket::QueueCollection.new(backend_class)
    end
  end

  # Adds data to a named queue. Triggers perform when the queue reaches its threshold.
  # @param queue [String] the queue name (must match a defined Batcher class)
  # @param data [Object] the data to add
  # @raise [Basket::BasketNotFoundError] if the queue class is not defined
  # @raise [Basket::Error] if basket_options are not configured on the class
  def self.add(queue, data)
    HandleAdd.call(queue, data)
  end

  # Searches a queue for elements matching the given block.
  # Routes to the correct backend when the queue class has a per-class backend configured.
  # @param queue [String] the queue name
  # @yield [data] block that receives each element's data
  # @return [Array<Basket::Element>] matching elements
  # @raise [Basket::BasketNotFoundError] if the queue class is not defined
  # @raise [Basket::EmptyBasketError] if the queue is empty
  def self.search(queue, &query)
    queue_collection_for_queue(queue).search(queue, query)
  end

  # Removes an element from a queue by its id.
  # Routes to the correct backend when the queue class has a per-class backend configured.
  # @param queue [String] the queue name
  # @param id [String] the element id
  # @return [Object] the removed element's data
  # @raise [Basket::ElementNotFoundError] if no element with that id exists
  def self.remove(queue, id)
    queue_collection_for_queue(queue).remove(queue, id)
  end

  # Returns the appropriate queue collection for a queue name, routing to
  # the per-class backend if one is configured on the queue class.
  # Falls back to the global queue collection if the class is not defined
  # or has no per-class backend.
  # @param queue [String] the queue name
  # @return [Basket::QueueCollection]
  def self.queue_collection_for_queue(queue)
    return queue_collection unless Object.const_defined?(queue)

    queue_class = Object.const_get(queue)
    backend_option = queue_class.basket_options_hash[:backend]
    if backend_option
      backend_class = Configuration.resolve_backend(backend_option)
      queue_collection_for(backend_class)
    else
      queue_collection
    end
  rescue Basket::Error
    queue_collection
  end
  private_class_method :queue_collection_for_queue

  # Resets all queue collections and their backends.
  # @return [void]
  def self.clear_all
    @monitor.synchronize do
      @queue_collection&.reset_backend
      @queue_collection = nil
      if @backend_queue_collections
        @backend_queue_collections.each_value(&:reset_backend)
        @backend_queue_collections = nil
      end
    end
  end
end
