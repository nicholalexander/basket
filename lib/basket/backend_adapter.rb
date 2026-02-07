# frozen_string_literal: true

module Basket
  # Abstract base class for backend storage adapters. Subclasses must
  # implement all public methods except {#with_lock}.
  class BackendAdapter
    # Returns all stored data across all queues.
    # @return [Hash{String => Array}]
    # @raise [NotImplementedError] if not overridden
    def data
      raise NotImplementedError, "must implement data"
    end

    # Pushes data onto the given queue.
    # @param queue [String] the queue name
    # @param data [Object] the data to store
    # @raise [NotImplementedError] if not overridden
    def push(queue, data)
      raise NotImplementedError, "must implement push with queue and data params"
    end

    # Returns the number of elements in the given queue.
    # @param queue [String] the queue name
    # @return [Integer]
    # @raise [NotImplementedError] if not overridden
    def length(queue)
      raise NotImplementedError, "must implement length with queue param"
    end

    # Returns all elements in the given queue.
    # @param queue [String] the queue name
    # @return [Array]
    # @raise [NotImplementedError] if not overridden
    def read(queue)
      raise NotImplementedError, "must implement read with queue param"
    end

    # Searches a queue for elements matching the block.
    # @param queue [String] the queue name
    # @yield [data] block that receives each element's data for matching
    # @return [Array]
    # @raise [NotImplementedError] if not overridden
    def search(queue, &block)
      raise NotImplementedError, "must implement search with queue and block params"
    end

    # Removes an element from a queue by id.
    # @param queue [String] the queue name
    # @param id [String] the element id
    # @return [Object, nil] the removed element or nil
    # @raise [NotImplementedError] if not overridden
    def remove(queue, id)
      raise NotImplementedError, "must implement remove with queue and id params"
    end

    # Clears all elements from the given queue.
    # @param queue [String] the queue name
    # @raise [NotImplementedError] if not overridden
    def clear(queue)
      raise NotImplementedError, "must implement clear with queue param"
    end

    # Acquires a per-queue lock and yields. Base implementation is a no-op.
    # @param queue [String] the queue name
    # @yield the block to execute while holding the lock
    def with_lock(queue)
      yield
    end
  end
end
