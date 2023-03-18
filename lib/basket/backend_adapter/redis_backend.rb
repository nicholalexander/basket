require "redis-namespace"

module Basket
  module BackendAdapter
    class RedisBackend
      attr_reader :client

      def initialize
        redis_connection = Redis.new
        @client = Redis::Namespace.new(:basket, redis: redis_connection)
      end

      def data
        response = {}

        @client.scan_each do |queue|
          response[queue] = deserialized_queue_data(queue)
        end

        response
      end

      def push(queue, data)
        # TODO: should we use JSON vs Marshal?
        marshalled_data = Marshal.dump(data)
        @client.lpush(queue, marshalled_data)
      end

      def length(queue)
        @client.llen(queue)
      end

      def pop_all(queue)
        results = deserialized_queue_data(queue)
        @client.del(queue)
        results
      end

      private

      def deserialized_queue_data(queue)
        @client.lrange(queue, 0, -1).reverse.map { |marshalled_data| Marshal.load(marshalled_data) }
      end
    end
  end
end
