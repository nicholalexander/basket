module Basket
  class Configuration
    def queue_collection
      @queue_collection ||= Basket::QueueCollection.new
    end

    def backend
      @backend ||= BackendAdapter::RedisBackend
    end
  end
end
