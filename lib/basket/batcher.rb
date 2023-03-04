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
        @basket_options
      end
    end

    def batch
      @batch ||= Basket.config[:queue].pop_all(self.class.name)
    end

    def on_success
    end

    def on_add
    end
  end
end
