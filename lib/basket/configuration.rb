# frozen_string_literal: true

module Basket
  # Holds global configuration for the Basket library.
  class Configuration
    # @return [String] Redis host address (default: "127.0.0.1")
    # @return [Integer] Redis port (default: 6379)
    # @return [Integer] Redis database number (default: 15)
    # @return [Symbol] Redis namespace (default: :basket)
    # @return [String, nil] Redis URL (overrides host/port/db when set)
    attr_accessor :redis_host, :redis_port, :redis_db, :namespace, :redis_url

    # @return [Class] the backend adapter class
    attr_reader :backend

    def initialize
      @redis_host = "127.0.0.1"
      @redis_port = 6379
      @redis_db = 15
      @backend = BackendAdapter::MemoryBackend
      @namespace = :basket
      @redis_url = nil
    end

    # Sets the backend adapter by symbol name.
    # @param backend [Symbol] :memory or :redis
    # @raise [Basket::Error] if the backend symbol is not recognized
    def backend=(backend)
      @backend = self.class.resolve_backend(backend)
    end

    # Resolves a backend symbol to its adapter class.
    # @param backend [Symbol] :memory or :redis
    # @return [Class] the backend adapter class
    # @raise [Basket::Error] if the backend symbol is not recognized
    def self.resolve_backend(backend)
      case backend
      when :memory
        BackendAdapter::MemoryBackend
      when :redis
        BackendAdapter::RedisBackend
      else
        raise Basket::Error, "Unknown Backend"
      end
    end
  end
end
