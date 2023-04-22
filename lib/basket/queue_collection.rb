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

    def search(queue, query)
      raise Basket::EmptyBasketError, "The basket #{queue} is empty." if length(queue).zero?
      raw_search_results = @backend.search(queue, &query)
      raw_search_results.map { |raw_search_result| Element.from_queue(raw_search_result) }
    end

    def remove(queue, id)
      raw_removed_element = @backend.remove(queue, id)
      Element.from_queue(raw_removed_element).data
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
