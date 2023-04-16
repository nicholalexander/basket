# frozen_string_literal: true

require_relative "basket/backend_adapter"
require_relative "basket/backend_adapter/memory_backend"
require_relative "basket/backend_adapter/redis_backend"
require_relative "basket/batcher"
require_relative "basket/configuration"
require_relative "basket/element"
require_relative "basket/error"
require_relative "basket/handle_add"
require_relative "basket/queue_collection"
require_relative "basket/version"

require "json"

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

  def self.peek(queue)
    queue_collection.read(queue)
  end

  def self.queue_collection
    @queue_collection ||= Basket::QueueCollection.new
  end

  def self.add(queue, data)
    HandleAdd.call(queue, data)
  end

  def self.search(queue, &query)
    queue_collection.search(queue, query)
  end

  def self.clear_all
    queue_collection.reset_backend
  end
end
