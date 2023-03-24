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

  def on_failure
    puts "wow, #{error.message} was loud"
    raise error
  end
end

class NonPerformantBasket
  include Basket::Batcher
  basket_options size: 1
end

class DummyErrorsBasket
  include Basket::Batcher

  def on_failure
    raise "This Error isn't raised!"
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
      Basket.add("DummyStockBasket", {stock: "IBM", purchased_price: 13_036})

      expect(Basket.contents).to eq({
        "DummyGroceryBasket" => [:milk],
        "DummyStockBasket" => [{purchased_price: 13_036, stock: "IBM"}]
      })
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
      expect(Basket.queue_collection.length("DummyStockBasket")).to eq(0)
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
      stubbed_baskets = Mocktail.of_next(DummyGroceryBasket, count: 2)
      performable_basket = stubbed_baskets[1]
      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      expect(DummyGroceryBasket.basket_options_hash).to eq({size: 2})

      verify { performable_basket.perform }
      verify { performable_basket.on_success }
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
    it "is called if perform raises an error" do
      stubbed_basket = DummyFireworksBasket.new
      allow(DummyFireworksBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:on_failure).and_call_original

      expect { Basket.add("DummyFireworksBasket", :bottle_rocket) }.to raise_error(/Boom/)

      expect(stubbed_basket).to have_received(:on_failure)
    end

    it "is not called if perform doesn't raise an error" do
      stubbed_baskets = Mocktail.of_next(DummyGroceryBasket, count: 2)
      performable_basket = stubbed_baskets[1]

      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      verify { performable_basket.perform }
      verify { performable_basket.on_add }
      verify { performable_basket.on_success }
      stubbed_baskets.each do |basket|
        expect(Mocktail.calls(basket, :on_failure).size).to eq(0)
      end
    end

    it "has the error available in the error variable so it can reraise or swallow that error" do
      stubbed_basket = DummyFireworksBasket.new
      allow(DummyFireworksBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:on_failure).and_call_original

      expect { Basket.add("DummyFireworksBasket", :bottle_rocket) }.to raise_error(/Boom/)

      expect(stubbed_basket.error).to be_a(RuntimeError)
      expect(stubbed_basket.error.message).to eq("Boom")
      expect($stdout).to have_received(:puts).with("wow, Boom was loud")
    end

    it "is not called when a Basket::Error is raised" do
      stubbed_basket = DummyErrorsBasket.new
      allow(DummyErrorsBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:on_failure).and_call_original

      expect { Basket.add("DummyErrorsBasket", "Nothing") }.to raise_error(Basket::Error)
      expect(stubbed_basket).not_to have_received(:on_failure)
    end
  end

  context "when perform is not defined" do
    it "raises an error" do
      expect do
        Basket.add("NonPerformantBasket",
          :nap)
      end.to raise_error(Basket::Error, "You must implement perform in your Basket class.")
    end
  end

  describe ".contents" do
    it "returns the values of all the queues" do
      Basket.add("DummyGroceryBasket", "Onions")
      Basket.add("DummyStockBasket", {ticker: "TSLA", value: 0})

      expect(Basket.contents).to eq(
        "DummyGroceryBasket" => ["Onions"],
        "DummyStockBasket" => [{ticker: "TSLA", value: 0}]
      )
      expect(Basket.contents).to be_an(Hash)
      expect(Basket.contents.keys.length).to eq(2)
    end
  end

  describe ".configure" do
    it "configures the redis host" do
      Basket.configure do |config|
        config.redis_host = "some_non_standard_host"
      end

      expect(Basket.config.redis_host).to eq("some_non_standard_host")
    end
  end
end
