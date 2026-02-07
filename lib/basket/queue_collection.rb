# frozen_string_literal: true

module Basket
  # Wraps a backend adapter and provides higher-level queue operations
  # with Element serialization/deserialization.
  class QueueCollection
    # @param backend [Class] the backend adapter class to instantiate
    def initialize(backend = Basket.config.backend)
      @backend = backend.new
    end

    # Wraps data in an Element and pushes it to the queue.
    # @param queue [String] the queue name
    # @param data [Object] the data to store
    # @return [Integer] the new queue length
    def push(queue, data)
      @backend.push(queue, Element.new(data))
      length(queue)
    end

    # Returns the number of elements in the queue.
    # @param queue [String] the queue name
    # @return [Integer]
    def length(queue)
      @backend.length(queue)
    end

    # Returns the data values for all elements in the queue.
    # @param queue [String] the queue name
    # @return [Array] the data values
    # @raise [Basket::BasketNotFoundError] if the queue class is not defined
    def read(queue)
      check_for_basket(queue)
      raw_queue = @backend.read(queue)
      raw_queue.map { |element| Element.from_queue(element).data }
    end

    # Searches a queue for elements matching the given proc.
    # @param queue [String] the queue name
    # @param query [Proc] a callable that receives element data
    # @return [Array<Basket::Element>] matching elements
    # @raise [Basket::BasketNotFoundError] if the queue class is not defined
    # @raise [Basket::EmptyBasketError] if the queue is empty
    def search(queue, query)
      check_for_basket(queue)
      check_for_zero_length(queue)
      raw_search_results = @backend.search(queue, &query)
      raw_search_results.map { |raw_search_result| Element.from_queue(raw_search_result) }
    end

    # Removes an element from the queue by id and returns its data.
    # @param queue [String] the queue name
    # @param id [String] the element id
    # @return [Object] the removed element's data
    # @raise [Basket::ElementNotFoundError] if no element with that id exists
    def remove(queue, id)
      raw_removed_element = @backend.remove(queue, id)
      check_for_raw_removed_element(raw_removed_element)
      Element.from_queue(raw_removed_element).data
    end

    # Clears all elements from the queue.
    # @param queue [String] the queue name
    # @return [void]
    def clear(queue)
      @backend.clear(queue)
    end

    # Delegates per-queue locking to the backend.
    # @param queue [String] the queue name
    # @yield the block to execute while holding the lock
    def with_lock(queue, &block)
      @backend.with_lock(queue, &block)
    end

    # Returns all queue data as a hash of queue names to Element arrays.
    # @return [Hash{String => Array<Basket::Element>}]
    def data
      raw = @backend.data
      raw.transform_values { |elements| elements.map { |e| Element.from_queue(e) } }
    end

    # Resets the backend to a fresh instance using the global config.
    # @return [void]
    def reset_backend
      @backend = Basket.config.backend.new
    end

    private

    def check_for_basket(queue)
      raise Basket::BasketNotFoundError unless Object.const_defined?(queue)
    end

    def check_for_zero_length(queue)
      raise Basket::EmptyBasketError, "The basket #{queue} is empty." if length(queue).zero?
    end

    def check_for_raw_removed_element(raw_removed_element)
      raise Basket::ElementNotFoundError if raw_removed_element.nil?
    end
  end
end
