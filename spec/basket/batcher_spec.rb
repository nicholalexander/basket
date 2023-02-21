RSpec.describe Basket::Batcher do
  class FlowerBasket
    include Basket::Batcher
    basket_options size: 15
  end

  describe "basket_options" do
    it "sets the basket_options_hash on the including class" do
      flower_basket = FlowerBasket.new

      expect(flower_basket.basket_options_hash).to eq({size: 15})
    end
  end
end
