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

    def call(queue = @queue, data = @data)
      queue_length = @queue_collection.push(queue, data)
      queue_class = class_for_queue
      queue_instance = queue_class.new

      queue_instance.define_singleton_method(:element) { data }
      queue_instance.on_add

      return unless basket_full?(queue_length, queue_class)

      queue_instance.perform
      queue_instance.on_success
      @queue_collection.clear(queue)
    rescue => e
      raise e if e.instance_of?(Basket::Error)

      queue_instance.define_singleton_method(:error) { e }
      queue_instance.on_failure
    end

    private

    def class_for_queue
      Object.const_get(@queue)
    end

    def basket_full?(queue_length, queue_class)
      queue_length == queue_class.basket_options_hash[:size]
    end
  end
end
