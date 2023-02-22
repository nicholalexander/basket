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
  end
end
