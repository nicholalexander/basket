class StockTrader
  def self.sell(stock)
    puts stock
  end
end

class DummyStockBasket
  include Basket::Batcher
  basket_options size: 3

  def perform
    batch.each do |stock|
      sell(stock)
    end
  end

  def sell(stock)
    StockTrader.sell(stock)
  end
end
