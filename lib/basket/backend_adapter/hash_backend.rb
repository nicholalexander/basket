module Basket
  module BackendAdapter
    class HashBackend
      attr_reader :data

      def initialize
        @data = {}
      end

      def push(queue, data)
        @data[queue] = [] if @data[queue].nil?
        @data[queue] <<= data
      end

      def length(queue)
        return 0 if @data[queue].nil?

        @data[queue].length
      end

      def pop_all(queue)
        @data.delete(queue)
      end
    end
  end
end
