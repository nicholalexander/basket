# frozen_string_literal: true

RSpec.describe Basket do
  it "has a version number" do
    expect(Basket::VERSION).not_to be nil
  end

  it "will do something useful in the future" do
    expect(true).to eq(true)
  end

  it "will perform an action when the basket is full" do
    Basket.config
    class GroceryBasket
      include Basket::Batcher
      basket_options size: 2

      def perform
        puts "Checkout"
      end
    end

    allow($stdout).to receive(:puts)

    Basket.add("GroceryBasket", :milk)
    Basket.add("GroceryBasket", :cookies)

    expect($stdout).to have_received(:puts).with("Checkout")
  end
end
