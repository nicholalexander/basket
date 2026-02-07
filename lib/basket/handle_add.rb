# frozen_string_literal: true

module Basket
  # Orchestrates adding data to a queue, checking the threshold, and
  # triggering perform when the batch is full. Handles per-queue locking
  # for atomicity and per-class backend routing.
  class HandleAdd
    # Adds data to the named queue. Triggers perform if the threshold is reached.
    # @param queue [String] the queue name (must match a defined Batcher class)
    # @param data [Object] the data to add
    # @raise [Basket::BasketNotFoundError] if the queue class is not defined
    def self.call(queue, data)
      new(queue, data).call
    end

    # @param queue [String] the queue name
    # @param data [Object] the data to add
    def initialize(queue, data)
      @queue = queue
      @data = data
    end

    # Executes the add-check-perform cycle under a per-queue lock.
    # @return [void]
    def call
      setup_batchers
      @queue_collection.with_lock(@queue) do
        add_to_basket
        perform if basket_full?(@queue_length, @queue_class)
      end
    rescue => error
      maybe_raise_basket_error(error)
      failure(error)
    end

    private

    def setup_batchers
      @queue_class = class_for_queue
      @queue_collection = queue_collection_for(@queue_class)
      @queue_instance = @queue_class.new
      @queue_instance.instance_variable_set(:@queue_collection, @queue_collection)
    end

    def add_to_basket(data = @data)
      @queue_length = @queue_collection.push(@queue, data)
      @queue_instance.instance_variable_set(:@element, data)
      @queue_instance.on_add
    end

    def perform
      @queue_instance.perform
      @queue_instance.on_success
      @queue_collection.clear(@queue)
    end

    def failure(error)
      @queue_instance.instance_variable_set(:@error, error)
      @queue_instance.on_failure
    end

    def queue_collection_for(queue_class)
      backend_option = queue_class.basket_options_hash[:backend]
      if backend_option
        backend_class = Basket::Configuration.resolve_backend(backend_option)
        Basket.queue_collection_for(backend_class)
      else
        Basket.queue_collection
      end
    end

    def class_for_queue
      raise_basket_not_found unless Object.const_defined?(@queue)
      Object.const_get(@queue)
    end

    def raise_basket_not_found
      raise Basket::BasketNotFoundError, "We couldn't find that basket anywhere, please make sure it is defined."
    end

    def basket_full?(queue_length, queue_class)
      queue_length >= queue_class.basket_options_hash[:size]
    end

    def maybe_raise_basket_error(e)
      raise e if e.is_a?(Basket::Error)
    end
  end
end
