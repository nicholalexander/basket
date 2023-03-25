module Basket
  module BackendAdapter
    class HashBackend
      def initialize
        @data = {}
      end

      attr_reader :data

      def push(queue, data)
        @data[queue] = [] if @data[queue].nil?
        @data[queue] <<= data
      end

      def length(queue)
        return 0 if @data[queue].nil?

        @data[queue].length
      end

      def read(queue)
        @data[queue]
      end

      def clear(queue)
        @data[queue] = []
      end

      def pop_all(queue)
        @data.delete(queue)
      end
    end
  end
end
