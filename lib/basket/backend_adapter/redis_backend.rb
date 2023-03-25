require "redis-namespace"

module Basket
  class BackendAdapter
    class RedisBackend < Basket::BackendAdapter
      attr_reader :client

      def initialize
        redis_connection = Redis.new(
          host: Basket.config.redis_host,
          port: Basket.config.redis_port,
          db: Basket.config.redis_db
        )

        @client = Redis::Namespace.new(
          Basket.config.namespace,
          redis: redis_connection
        )
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

      def clear(queue)
        @client.del(queue)
      end

      def read(queue)
        deserialized_queue_data(queue)
      end

      private

      def deserialized_queue_data(queue)
        @client.lrange(queue, 0, -1).reverse.map { |marshalled_data| Marshal.load(marshalled_data) }
      end
    end
  end
end
