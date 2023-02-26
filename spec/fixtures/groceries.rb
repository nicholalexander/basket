class Bag
  def self.add(groceries)
  end
end

class DummyGroceryBasket
  include Basket::Batcher
  basket_options size: 2

  def perform
    puts "Checkout"
  end

  def on_success
    Bag.add(batch)
  end
end
