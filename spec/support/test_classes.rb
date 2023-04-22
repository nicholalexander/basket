class PlaylistBasket
  include Basket::Batcher
  basket_options size: 2

  def perform
    puts "Playing #{batch}"
  end
end

class DummyGroceryBasket
  include Basket::Batcher
  basket_options size: 2

  def perform
    puts "Checkout"
  end

  def on_add
    puts "Check coupons for #{element}"
  end

  def on_success
    puts "Add #{batch} to bag"
  end
end

class DummyStockBasket
  include Basket::Batcher
  basket_options size: 3

  def perform
    batch.each do |stock|
      puts stock
    end
  end

  def on_add
    puts "Check for insider trading on #{element[:ticker]}"
  end
end

class DummyFireworksBasket
  include Basket::Batcher
  basket_options size: 1

  def perform
    raise "Boom"
  end

  def on_failure
    puts "wow, #{error.message} was loud"
    raise error
  end
end

class NonPerformantBasket
  include Basket::Batcher
  basket_options size: 1
end

class DummyErrorsBasket
  include Basket::Batcher

  def on_failure
    raise "This Error isn't raised!"
  end
end

class BatchBugBasket
  include Basket::Batcher
  basket_options size: 1

  def on_add
    puts batch
  end

  def perform
    puts batch
  end

  def on_success
    puts batch
  end
end

class DummySearchAndDestroyBasket
  include Basket::Batcher
  basket_options size: 10
end

class DummyEmptyBasket
  include Basket::Batcher
  basket_options size: 1

  def perform
  end
end

class PizzaBasket
  include Basket::Batcher
  basket_options size: 10
end
