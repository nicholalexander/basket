module Basket
  class BackendAdapter
    def data
      raise NotImplementedError, "must implement data"
    end

    def push(queue, data)
      raise NotImplementedError, "must implement push with queue and data params"
    end

    def length(queue)
      raise NotImplementedError, "must implement length with queue param"
    end

    def read(queue)
      raise NotImplementedError, "must implement read with queue param"
    end

    def search(queue, &block)
      raise NotImplementedError, "must implement search with queue and block params"
    end

    def remove(queue, id)
      raise NotImplementedError, "must implement remove with queue and id params"
    end

    def clear(queue)
      raise NotImplementedError, "must implement clear with queue param"
    end
  end
end
