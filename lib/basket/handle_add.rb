module Basket
  class HandleAdd
    def initialize(queue, data)
      @queue = queue
      @data = data
    end

    def call(queue = @queue, data = @data)
      queue_length = Basket.queue_collection.push(queue, data)
      queue_class = Object.const_get(queue)
      queue_instance = queue_class.new

      queue_instance.define_singleton_method(:element) { data }
      queue_instance.on_add

      return unless queue_length == queue_class.basket_options_hash[:size]

      queue_instance.perform
      queue_instance.on_success
    rescue => e
      raise e if e.instance_of?(Basket::Error)

      queue_instance.define_singleton_method(:error) { e }
      queue_instance.on_failure
    end
  end
end
