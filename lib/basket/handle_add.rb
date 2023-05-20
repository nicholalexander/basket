module Basket
  class HandleAdd
    def self.call(queue, data)
      new(queue, data).call
    end

    def initialize(queue, data)
      @queue = queue
      @data = data
    end

    def call
      setup_batchers
      add_to_basket
      perform if basket_full?(@queue_length, @queue_class)
    rescue => error
      maybe_raise_basket_error(error)
      failure(error)
    end

    private

    def setup_batchers
      @queue_collection = Basket.queue_collection
      @queue_class = class_for_queue
      @queue_instance = @queue_class.new
    end

    def add_to_basket(data = @data)
      @queue_length = @queue_collection.push(@queue, data)
      @queue_instance.define_singleton_method(:element) { data }
      @queue_instance.on_add
    end

    def perform
      @queue_instance.perform
      @queue_instance.on_success
      @queue_collection.clear(@queue)
    end

    def failure(error)
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
      queue_length >= queue_class.basket_options_hash[:size]
    end

    def maybe_raise_basket_error(e)
      raise e if e.instance_of?(Basket::Error)
      raise e if e.instance_of?(Basket::BasketNotFoundError)
    end
  end
end
