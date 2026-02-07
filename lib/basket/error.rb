# frozen_string_literal: true

module Basket
  # Base error class for all Basket errors.
  class Error < StandardError; end

  # Raised when a queue name does not correspond to a defined Batcher class.
  class BasketNotFoundError < Error; end

  # Raised when searching an empty queue.
  class EmptyBasketError < Error; end

  # Raised when removing an element by id that does not exist.
  class ElementNotFoundError < Error; end
end
