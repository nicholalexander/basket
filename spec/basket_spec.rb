# frozen_string_literal: true

class DummyGroceryBasket
  include Basket::Batcher
  basket_options size: 2

  class Bag
    def self.add(groceries)
    end
  end

  def perform
    puts "Checkout"
  end

  def on_success
    DummyGroceryBasket::Bag.add(batch)
  end
end

class DummyStockBasket
  include Basket::Batcher
  basket_options size: 3

  class StockTrader
    def self.sell(stock)
      puts stock
    end
  end

  def perform
    batch.each do |stock|
      sell(stock)
    end
  end

  def sell(stock)
    StockTrader.sell(stock)
  end
end

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
      expect(DummyStockBasket::StockTrader).to receive(:sell).with({ticker: :ibm, price: 1234}).ordered
      expect(DummyStockBasket::StockTrader).to receive(:sell).with({ticker: :apl, price: 2345}).ordered
      expect(DummyStockBasket::StockTrader).to receive(:sell).with({ticker: :asdf, price: 345}).ordered

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
      allow(DummyGroceryBasket::Bag).to receive(:add)

      Basket.add("DummyGroceryBasket", :pene)
      Basket.add("DummyGroceryBasket", :tomatos)

      expect(stubbed_basket).to have_received(:on_success)
      expect(DummyGroceryBasket::Bag).to have_received(:add)
    end

    it "is not called if perform raises an error"

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
