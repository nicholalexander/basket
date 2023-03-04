# frozen_string_literal: true

class DummyGroceryBasket
  include Basket::Batcher
  basket_options size: 2

  def perform
    puts "Checkout"
  end

  def on_add
    puts "Check coupons for #{element}"
  end

  def on_success
    puts "Add #{batch} to bag"
  end
end

class DummyStockBasket
  include Basket::Batcher
  basket_options size: 3

  def perform
    batch.each do |stock|
      puts stock
    end
  end

  def on_add
    puts "Check for insider trading on #{element[:ticker]}"
  end
end

class DummyFireworksBasket
  include Basket::Batcher
  basket_options size: 1

  def perform
    raise "Boom"
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
    allow($stdout).to receive(:puts)
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
      stubbed_baskets = Mocktail.of_next(DummyGroceryBasket, count: 2)
      performable_basket = stubbed_baskets[1]
      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      expect(DummyGroceryBasket.basket_options_hash).to eq({size: 2})

      verify { performable_basket.perform }
    end

    it "processes the batch" do
      stubbed_basket = DummyStockBasket.new
      allow(DummyStockBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original

      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})
      Basket.add("DummyStockBasket", {ticker: :apl, price: 2345})
      Basket.add("DummyStockBasket", {ticker: :asdf, price: 345})

      expect(stubbed_basket).to have_received(:perform)
      expect(Basket.config[:queue].length("DummyStockBasket")).to eq(0)
      expect($stdout).to have_received(:puts).with({price: 1234, ticker: :ibm})
      expect($stdout).to have_received(:puts).with({price: 2345, ticker: :apl})
      expect($stdout).to have_received(:puts).with({price: 345, ticker: :asdf})
    end
  end

  describe "#on_add" do
    it "is called each time an element is added" do
      stubbed_baskets = Mocktail.of_next(DummyStockBasket, count: 2)

      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})
      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})

      verify { stubbed_baskets[0].on_add }
      verify { stubbed_baskets[1].on_add }
    end

    it "has access to the element through the element variable" do
      stubbed_basket = Mocktail.of_next(DummyStockBasket)

      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})

      expect(stubbed_basket.element).to eq({ticker: :ibm, price: 1234})
    end
  end

  describe "#on_success" do
    it "is called after perform" do
      stubbed_basket = DummyGroceryBasket.new
      allow(DummyGroceryBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original
      allow(stubbed_basket).to receive(:on_success).and_call_original

      Basket.add("DummyGroceryBasket", :pene)
      Basket.add("DummyGroceryBasket", :tomatos)

      expect(stubbed_basket).to have_received(:on_success)
      expect($stdout).to have_received(:puts).with("Add [:pene, :tomatos] to bag")
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
