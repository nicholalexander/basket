# frozen_string_literal: true

require_relative "fixtures/groceries"
require_relative "fixtures/stocks"
require_relative "fixtures/fireworks"

RSpec.describe Basket do
  it "has a version number" do
    expect(Basket::VERSION).not_to be nil
  end

  it "will do something useful in the future" do
    expect(true).to eq(true)
  end

  before do
    Basket.config
    Basket.clear_all
  end

  describe "#add" do
    it "allows you to track multiple baskets" do
      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyStockBasket", {stock: "IBM", purchased_price: 13036})

      expect(Basket.contents).to eq({"DummyGroceryBasket" => [:milk], "DummyStockBasket" => [{purchased_price: 13036, stock: "IBM"}]})
    end
  end

  describe "#perform" do
    it "will perform an action when the basket is full" do
      stubbed_basket = DummyGroceryBasket.new
      allow(DummyGroceryBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original

      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      expect(DummyGroceryBasket.basket_options_hash).to eq({size: 2})
      expect(stubbed_basket).to have_received(:perform)
    end

    it "processes the batch" do
      stubbed_basket = DummyStockBasket.new
      allow(DummyStockBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original
      expect(StockTrader).to receive(:sell).with({ticker: :ibm, price: 1234}).ordered
      expect(StockTrader).to receive(:sell).with({ticker: :apl, price: 2345}).ordered
      expect(StockTrader).to receive(:sell).with({ticker: :asdf, price: 345}).ordered

      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})
      Basket.add("DummyStockBasket", {ticker: :apl, price: 2345})
      Basket.add("DummyStockBasket", {ticker: :asdf, price: 345})

      expect(stubbed_basket).to have_received(:perform)
      expect(Basket.config[:queue].length("DummyStockBasket")).to eq(0)
    end
  end

  describe "#on_success" do
    it "is called after perform" do
      stubbed_basket = DummyGroceryBasket.new
      allow(DummyGroceryBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original
      allow(stubbed_basket).to receive(:on_success).and_call_original
      allow(Bag).to receive(:add)

      Basket.add("DummyGroceryBasket", :pene)
      Basket.add("DummyGroceryBasket", :tomatos)

      expect(stubbed_basket).to have_received(:on_success)
      expect(Bag).to have_received(:add)
    end

    it "is not called if perform raises an error" do
      stubbed_basket = DummyFireworksBasket.new
      allow(DummyFireworksBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original
      allow(stubbed_basket).to receive(:on_success).and_call_original

      expect { Basket.add("DummyFireworksBasket", :bottle_rocket) }.to raise_error(/Boom/)
      expect(stubbed_basket).to have_received(:perform)
      expect(stubbed_basket).to_not have_received(:on_success)
    end

    it "does nothing if the class does not define it" do
      stubbed_basket = DummyStockBasket.new
      allow(DummyStockBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original
      allow(stubbed_basket).to receive(:on_success).and_call_original

      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})
      Basket.add("DummyStockBasket", {ticker: :apl, price: 2345})
      Basket.add("DummyStockBasket", {ticker: :asdf, price: 345})

      expect(stubbed_basket).to have_received(:perform)
      expect(stubbed_basket).to have_received(:on_success)
    end
  end

  describe "#on_failure" do
    it "is called if perform raises an error"
    it "has the error available to it so it can reraise or swallow that error?"
  end
end
