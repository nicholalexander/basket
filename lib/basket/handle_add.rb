module Basket
  class HandleAdd
    def self.call(queue, data)
      new(queue, data).call
    end

    def initialize(queue, data)
      @queue = queue
      @data = data
    end

    def call(data = @data)
      setup_batchers
      run_lifecycle
    end

    private

    def setup_batchers
      @queue_collection = Basket.queue_collection
      @queue_class = class_for_queue
      @queue_instance = @queue_class.new
    end

    def run_lifecycle(data = @data)
      queue_length = @queue_collection.push(@queue, data)
      @queue_instance.define_singleton_method(:element) { data }
      @queue_instance.on_add

      return unless basket_full?(queue_length, @queue_class)

      @queue_instance.perform
      @queue_instance.on_success
      @queue_collection.clear(@queue)
    rescue => error
      raise error if basket_error?(error)

      @queue_instance.define_singleton_method(:error) { error }
      @queue_instance.on_failure
    end

    def class_for_queue
      raise_basket_not_found unless Object.const_defined?(@queue)
      Object.const_get(@queue)
    end

    def raise_basket_not_found
      raise Basket::BasketNotFoundError, "We couldn't find that basket anywhere, please make sure it is defined."
    end

    def basket_full?(queue_length, queue_class)
      queue_length == queue_class.basket_options_hash[:size]
    end

    def basket_error?(e)
      e.instance_of?(Basket::Error) || e.instance_of?(Basket::BasketNotFoundError)
    end
  end
end
