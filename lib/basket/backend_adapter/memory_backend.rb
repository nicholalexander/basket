# frozen_string_literal: true

require "monitor"

module Basket
  class BackendAdapter
    # Thread-safe in-memory backend adapter using MonitorMixin.
    # All public methods are synchronized for safe concurrent access.
    class MemoryBackend < Basket::BackendAdapter
      include MonitorMixin

      def initialize
        super()
        @data = {}
        @queue_locks = {}
        @queue_locks_mutex = Mutex.new
      end

      # Returns a defensive copy of the data hash of all queues.
      # @return [Hash{String => Array<Basket::Element>}]
      def data
        synchronize { @data.transform_values(&:dup) }
      end

      # Pushes an element onto the given queue.
      # @param queue [String] the queue name
      # @param data [Basket::Element] the element to store
      # @return [void]
      def push(queue, data)
        synchronize do
          @data[queue] ||= []
          @data[queue] << data
        end
      end

      # Returns the number of elements in the given queue.
      # @param queue [String] the queue name
      # @return [Integer] the queue length, or 0 if the queue does not exist
      def length(queue)
        synchronize do
          return 0 if @data[queue].nil?

          @data[queue].length
        end
      end

      # Returns all elements in the given queue.
      # @param queue [String] the queue name
      # @return [Array<Basket::Element>] the elements, or an empty array
      def read(queue)
        synchronize { @data[queue] || [] }
      end

      # Searches a queue for elements whose data matches the block.
      # @param queue [String] the queue name
      # @yield [data] block that receives each element's data for matching
      # @return [Array<Basket::Element>] matching elements
      def search(queue, &block)
        synchronize do
          return [] unless @data[queue]
          @data[queue].select { |element| block.call(element.data) }
        end
      end

      # Removes an element from a queue by id.
      # @param queue [String] the queue name
      # @param id [String] the element id
      # @return [Basket::Element, nil] the removed element, or nil if not found
      def remove(queue, id)
        synchronize do
          return nil unless @data[queue]
          index = @data[queue].index { |element| element.id == id }
          return nil if index.nil?
          @data[queue].delete_at(index)
        end
      end

      # Clears all elements from the given queue.
      # @param queue [String] the queue name
      # @return [Array] an empty array
      def clear(queue)
        synchronize { @data[queue] = [] }
      end

      # Acquires a per-queue Mutex lock and yields the block.
      # @param queue [String] the queue name
      # @yield the block to execute while holding the lock
      def with_lock(queue)
        lock = @queue_locks_mutex.synchronize do
          @queue_locks[queue] ||= Mutex.new
        end
        lock.synchronize { yield }
      end
    end
  end
end
