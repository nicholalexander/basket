class DummyFireworksBasket
  include Basket::Batcher
  basket_options size: 1

  def perform
    raise "Boom"
  end
end
