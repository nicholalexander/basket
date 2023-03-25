module Basket
  class BackendAdapter
    def data
      raise "must implement data"
    end

    def push(queue, data)
      raise "must implement push with queue and data params"
    end

    def length(queue)
      raise "must implement length with queue param"
    end

    def read(queue)
      raise "must implement read with queue param"
    end

    def clear(queue)
      raise "must implement clear with queue param"
    end
  end
end
