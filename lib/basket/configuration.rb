module Basket
  class Configuration
    attr_accessor :redis_host, :redis_port, :redis_db
    attr_reader :backend

    def initialize
      @redis_host = "127.0.0.1"
      @redis_port = 6379
      @redis_db = 15
      @backend = BackendAdapter::HashBackend
    end

    def backend=(backend)
      case backend
      when :hash
        @backend = BackendAdapter::HashBackend
      when :redis
        @backend = BackendAdapter::RedisBackend
      end
    end
  end
end
