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
end
