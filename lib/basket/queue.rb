module Basket
  class Queue
    def initialize(backend = HashBackend.new)
      @backend = backend
    end

    def push(queue, data)
      @backend.push(queue, data)
      length(queue)
    end

    def length(queue)
      @backend.length(queue)
    end

    def pop_all(queue)
      @backend.pop_all(queue)
    end

    def data
      @backend.data
    end
  end
end
