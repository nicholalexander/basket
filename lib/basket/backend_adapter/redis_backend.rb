require "redis"

module Basket
  module BackendAdapter
    class RedisBackend
      attr_reader :client

      def initialize
        @client = Redis.new(host: "127.0.0.1", port: 6379, db: 15)
      end

      def data
        response = {}

        @client.keys("*basket::*").each do |queue_with_namespace|
          response[queue_with_namespace.split("::").last] = @client.lrange(queue_with_namespace, 0, -1).reverse.map { |marshalled_data| Marshal.load(marshalled_data) }
        end

        response
      end

      def push(queue, data)
        marshalled_data = Marshal.dump(data)
        @client.lpush("basket::#{queue}", marshalled_data)
      end

      def length(queue)
        @client.llen("basket::#{queue}")
      end

      def pop_all(queue)
        results = @client.lrange("basket::#{queue}", 0, -1).reverse.map { |marshalled_data| Marshal.load(marshalled_data) }
        @client.del("basket::#{queue}")
        results
      end

      # get redis client
      # line up the interface ^ with the redis client interface
      # add redis client config
      # make sure this doesn't blow up if you don't have redis
      # prefix queues so we don't mess with non-basket redis values
    end
  end
end
