# frozen_string_literal: true

class DummyGroceryBasket
  include Basket::Batcher
  basket_options size: 2

  def perform
    puts "Checkout"
  end
end

class DummyStockBasket
  include Basket::Batcher
  basket_options size: 3

  def perform
    sell(batch)
  end

  def sell
    puts ap batch
  end
end

RSpec.describe Basket do
  it "has a version number" do
    expect(Basket::VERSION).not_to be nil
  end

  it "will do something useful in the future" do
    expect(true).to eq(true)
  end

  describe "#add" do
    it "allows you to track multiple baskets" do
      Basket.config

      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyStockBasket", {stock: "IBM", purchased_price: 13036})

      expect(Basket.contents).to eq({"DummyGroceryBasket" => [:milk], "DummyStockBasket" => [{purchased_price: 13036, stock: "IBM"}]})
    end
  end

  describe "#perform" do
    it "will perform an action when the basket is full" do
      Basket.config

      stubbed_basket = DummyGroceryBasket.new
      allow(DummyGroceryBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original

      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      expect(DummyGroceryBasket.basket_options_hash).to eq({size: 2})
      expect(stubbed_basket).to have_received(:perform)
    end

    it "resets"
    it "will make the batch available to perform"
  end

  describe "#on_success" do
    it "is called after perform"
    it "is not called if perform raises an error"
  end

  describe "#on_failure" do
    it "is called if perform raises an error"
    it "has the error available to it so it can reraise or swallow that error?"
  end
end
