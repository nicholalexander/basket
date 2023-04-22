module Basket
  class Error < StandardError; end

  class BasketNotFoundError < Error; end

  class EmptyBasketError < Error; end
end
