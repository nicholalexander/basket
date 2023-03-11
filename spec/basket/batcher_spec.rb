class FlowerBasket
  include Basket::Batcher
  basket_options size: 15
end

class SillyBasket
  include Basket::Batcher
end

class NegativeBasket
  include Basket::Batcher
  basket_options size: 0
end

RSpec.describe Basket::Batcher do
  describe "basket_options" do
    it "sets the basket_options_hash on the including class" do
      expect(FlowerBasket.basket_options_hash).to eq({size: 15})
    end

    it "raises a Basket::Error if size is not specified" do
      expect { Basket.add("SillyBasket", "bingo") }.to raise_error(Basket::Error, /specify the size/)
    end

    it "raises a Basket::Error if size is not <= to 0" do
      expect { Basket.add("NegativeBasket", "bingo") }.to raise_error(Basket::Error, /greater than 0/)
    end
  end

  describe "#batch" do
    it "pulls the data from the queue for the class" do
      Basket.queue_collection.push("FlowerBasket", 10)
      Basket.queue_collection.push("FlowerBasket", 12)
      flower_basket = FlowerBasket.new
      expect(flower_basket.batch).to eq([10, 12])
    end
  end

  describe "#perform" do
    it "raises an error that tells the developer they need to define perform" do
      flower_basket = FlowerBasket.new
      expect { flower_basket.perform }.to raise_error("You must implement perform in your Basket class.")
    end
  end
end
