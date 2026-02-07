# frozen_string_literal: true

begin
  require "redis-namespace"
rescue LoadError
  # redis-namespace is optional; RedisBackend will raise on use
end

module Basket
  class BackendAdapter
    # Redis-backed storage adapter. Requires the redis and redis-namespace gems.
    class RedisBackend < Basket::BackendAdapter
      # @return [Redis::Namespace] the namespaced Redis client
      attr_reader :client

      # Initializes the Redis connection using global configuration.
      # @raise [Basket::Error] if redis or redis-namespace gems are not installed
      def initialize
        unless defined?(Redis) && defined?(Redis::Namespace)
          raise Basket::Error,
            "Redis backend requires the 'redis' and 'redis-namespace' gems. " \
            "Add them to your Gemfile: gem 'redis' and gem 'redis-namespace'"
        end

        redis_connection = select_redis_connection

        @client = Redis::Namespace.new(
          Basket.config.namespace,
          redis: redis_connection
        )
      end

      # Returns all stored data across all queues.
      # @return [Hash{String => Array<Hash>}]
      def data
        response = {}

        @client.scan_each do |queue|
          response[queue] = deserialized_queue_data(queue)
        end

        response
      end

      # Searches a queue for elements whose data matches the block.
      # @param queue [String] the queue name
      # @yield [data] block that receives each element's deserialized data
      # @return [Array<Hash>] matching elements as hashes
      def search(queue, &block)
        deserialized_queue_data(queue).select { |raw_element| block.call(raw_element["data"]) }
      end

      # Removes an element from a queue by id.
      # @param queue [String] the queue name
      # @param element_id [String] the element id
      # @return [Hash, nil] the removed element as a hash, or nil if not found
      def remove(queue, element_id)
        element = deserialized_queue_data(queue).find { |raw_element| raw_element["id"] == element_id }
        return nil unless element
        @client.lrem(queue, 1, element.to_json)
        element
      end

      # Pushes serialized data onto the given queue.
      # @param queue [String] the queue name
      # @param data [Basket::Element] the element to store
      # @return [Integer] the new length of the list
      def push(queue, data)
        @client.lpush(queue, serialize_data(data))
      end

      # Returns the number of elements in the given queue.
      # @param queue [String] the queue name
      # @return [Integer] the queue length
      def length(queue)
        @client.llen(queue)
      end

      # Clears all elements from the given queue.
      # @param queue [String] the queue name
      # @return [void]
      def clear(queue)
        @client.del(queue)
      end

      # Returns all elements in the given queue.
      # @param queue [String] the queue name
      # @return [Array<Hash>] deserialized elements
      def read(queue)
        deserialized_queue_data(queue)
      end

      # Acquires an advisory lock on Redis using SET EX NX (atomic set-with-expiry).
      # @param queue [String] the queue name
      # @yield the block to execute while holding the lock
      # @raise [Basket::Error] if the lock cannot be acquired after 50 attempts
      def with_lock(queue)
        lock_key = "#{queue}:lock"
        acquired = false
        begin
          50.times do
            acquired = @client.set(lock_key, "1", ex: 10, nx: true)
            break if acquired
            sleep(0.01)
          end
          raise Basket::Error, "Could not acquire lock for queue: #{queue}" unless acquired
          yield
        ensure
          @client.del(lock_key) if acquired
        end
      end

      private

      def serialize_data(data)
        JSON.generate(data)
      end

      def deserialized_queue_data(queue)
        @client.lrange(queue, 0, -1).reverse.map { |serialized_data| JSON.parse(serialized_data) }
      end

      def select_redis_connection
        if Basket.config.redis_url
          redis_connection_from_url
        else
          redis_connection_from_host
        end
      end

      def redis_connection_from_host
        Redis.new(
          host: Basket.config.redis_host,
          port: Basket.config.redis_port,
          db: Basket.config.redis_db
        )
      end

      def redis_connection_from_url
        Redis.new(
          url: Basket.config.redis_url
        )
      end
    end
  end
end
