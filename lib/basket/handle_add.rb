module Basket
  class HandleAdd
    def self.call(queue, data)
      new(queue, data).call
    end

    def initialize(queue, data)
      @queue = queue
      @data = data
      @queue_collection = Basket.queue_collection
    end

    def call(data = @data)
      queue_length = @queue_collection.push(@queue, data)
      queue_class = class_for_queue
      queue_instance = queue_class.new

      queue_instance.define_singleton_method(:element) { data }
      queue_instance.on_add

      return unless basket_full?(queue_length, queue_class)

      queue_instance.perform
      queue_instance.on_success
      @queue_collection.clear(@queue)
    rescue => e
      raise e if basket_error?(e)

      queue_instance.define_singleton_method(:error) { e }
      queue_instance.on_failure
    end

    private

    def class_for_queue
      Object.const_get(@queue)
    rescue NameError => e
      raise Basket::BasketNotFoundError, "We couldn't find that basket anywhere, please make sure it is defined. | #{e.message}"
    end

    def basket_full?(queue_length, queue_class)
      queue_length == queue_class.basket_options_hash[:size]
    end

    def basket_error?(e)
      e.instance_of?(Basket::Error) || e.instance_of?(Basket::BasketNotFoundError)
    end
  end
end
