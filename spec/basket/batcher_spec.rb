class FlowerBasket
  include Basket::Batcher
  basket_options size: 15
end

RSpec.describe Basket::Batcher do
  describe "basket_options" do
    it "sets the basket_options_hash on the including class" do
      expect(FlowerBasket.basket_options_hash).to eq({size: 15})
    end
  end

  describe "#batch" do
    it "pulls the data from the queue for the class" do
      Basket.config.queue_collection.push("FlowerBasket", 10)
      Basket.config.queue_collection.push("FlowerBasket", 12)
      flower_basket = FlowerBasket.new
      expect(flower_basket.batch).to eq([10, 12])
    end
  end
end
