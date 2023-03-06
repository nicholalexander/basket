module Basket
  module Batcher
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def basket_options(args)
        @basket_options = args
      end

      def basket_options_hash
        raise Basket::Error, "You must specify the size of your basket!" if @basket_options.nil?
        raise Basket::Error, "You must specify a size greater than 0" if @basket_options[:size] <= 0
        @basket_options
      end
    end

    def batch
      @batch ||= Basket.config.queue_collection.pop_all(self.class.name)
    end

    def perform
      raise Basket::Error, "You must implement perform in your Basket class."
    end

    def on_success
    end

    def on_add
    end

    def on_failure
      raise error
    end
  end
end
