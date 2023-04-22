module Basket
  class Error < StandardError; end

  class BasketNotFoundError < Error; end

  class EmptyBasketError < Error; end

  class ElementNotFoundError < Error; end
end
