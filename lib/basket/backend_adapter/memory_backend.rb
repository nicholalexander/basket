module Basket
  class BackendAdapter
    class MemoryBackend < Basket::BackendAdapter
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

      def search(queue, &block)
        @data[queue].select { |raw_element| block.call(raw_element) }
      end

      def clear(queue)
        @data[queue] = []
      end
    end
  end
end
