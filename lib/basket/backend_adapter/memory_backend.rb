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
        @data[queue].select { |element| block.call(element.data) }
      end

      def remove(queue, id)
        index_of_element_to_delete = @data[queue].index { |element| element.id == id }
        @data[queue].delete_at(index_of_element_to_delete)
      rescue
        nil
      end

      def clear(queue)
        @data[queue] = []
      end
    end
  end
end
