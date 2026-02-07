# frozen_string_literal: true

module Basket
  # Include this module in a class to define a batching basket.
  # The including class must call {ClassMethods#basket_options} and implement {#perform}.
  #
  # @example
  #   class MyBasket
  #     include Basket::Batcher
  #     basket_options size: 10
  #
  #     def perform
  #       batch.each { |item| process(item) }
  #     end
  #   end
  module Batcher
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class-level DSL methods added to the including class.
    module ClassMethods
      # Configures the basket options.
      # @param args [Hash] options hash
      # @option args [Integer] :size the batch threshold (required, must be > 0)
      # @option args [Symbol] :backend optional per-class backend (:memory or :redis)
      def basket_options(args)
        @basket_options = args
      end

      # Returns the configured basket options hash.
      # @return [Hash]
      # @raise [Basket::Error] if basket_options was not called
      # @raise [Basket::Error] if size is <= 0
      def basket_options_hash
        raise Basket::Error, "You must specify the size of your basket!" if @basket_options.nil?
        raise Basket::Error, "You must specify a size greater than 0" if @basket_options[:size] <= 0

        @basket_options
      end
    end

    # @return [Object] the most recently added element (set during on_add)
    # @return [StandardError] the error that occurred (set during on_failure)
    attr_reader :element, :error

    # Returns the current batch of data from the queue.
    # @return [Array]
    def batch
      @batch ||= (@queue_collection || Basket.queue_collection).read(self.class.name)
    end

    # Override this method to define the batch processing logic.
    # @raise [Basket::Error] if not overridden
    def perform
      raise Basket::Error, "You must implement perform in your Basket class."
    end

    # Called after {#perform} completes successfully. Override to add post-processing.
    # @return [void]
    def on_success
    end

    # Called each time an element is added to the queue. Override to add per-element logic.
    # @return [void]
    def on_add
    end

    # Called when an error occurs during {#perform} or callbacks. Override to customize.
    # @raise [StandardError] re-raises the error by default
    def on_failure
      raise error
    end
  end
end
