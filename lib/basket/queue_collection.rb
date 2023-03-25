module Basket
  class QueueCollection
    def initialize(backend = Basket.config.backend)
      @backend = backend.new
    end

    def push(queue, data)
      @backend.push(queue, data)
      length(queue)
    end

    def length(queue)
      @backend.length(queue)
    end

    def read(queue)
      @backend.read(queue)
    end

    def clear(queue)
      @backend.clear(queue)
    end

    def data
      @backend.data
    end

    def reset_backend
      @backend = Basket.config.backend.new
    end
  end
end
