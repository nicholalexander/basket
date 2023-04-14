module Basket
  class QueueCollection
    def initialize(backend = Basket.config.backend)
      @backend = backend.new
    end

    def push(queue, data)
      @backend.push(queue, Element.new(data))
      length(queue)
    end

    def length(queue)
      @backend.length(queue)
    end

    def read(queue)
      raw_queue = @backend.read(queue)
      raw_queue.map { |element| Element.from_queue(element).data }
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
