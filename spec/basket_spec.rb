# frozen_string_literal: true

RSpec.describe Basket do
  it "has a version number" do
    expect(Basket::VERSION).not_to be nil
  end

  before do
    Basket.clear_all
    allow($stdout).to receive(:puts)
  end

  describe ".add" do
    it "allows you to track multiple baskets" do
      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyStockBasket", {stock: "IBM", purchased_price: 13_036})

      expect(Basket.peek("DummyGroceryBasket")).to eq([:milk])
      expect(Basket.peek("DummyStockBasket")).to eq([{purchased_price: 13_036, stock: "IBM"}])
    end

    it "raises a helpful error if the basket doesn't exist" do
      expect {
        Basket.add("NonExistantBasket", :milk)
      }.to raise_error(Basket::BasketNotFoundError).with_message("We couldn't find that basket anywhere, please make sure it is defined.")
    end
  end

  describe ".perform" do
    it "will call perform when the basket is full" do
      stubbed_baskets = Mocktail.of_next(DummyGroceryBasket, count: 2)
      performable_basket = stubbed_baskets[1]
      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      expect(DummyGroceryBasket.basket_options_hash).to eq({size: 2})

      verify { performable_basket.perform }
    end

    it "performs the action when the basket is full" do
      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      expect($stdout).to have_received(:puts).with("Checkout")
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

    context "when perform is not defined" do
      it "raises an error" do
        expect do
          Basket.add("NonPerformantBasket",
            :nap)
        end.to raise_error(Basket::Error, "You must implement perform in your Basket class.")
      end
    end
  end

  describe ".on_add" do
    it "is called each time an element is added" do
      stubbed_baskets = Mocktail.of_next(DummyStockBasket, count: 2)

      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})
      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})

      verify { stubbed_baskets[0].on_add }
      verify { stubbed_baskets[1].on_add }
    end

    it "has access to the element through the element variable" do
      stubbed_basket = DummyStockBasket.new
      allow(DummyStockBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:on_add).and_call_original

      Basket.add("DummyStockBasket", {ticker: :ibm, price: 1234})

      expect(stubbed_basket.element).to eq({ticker: :ibm, price: 1234})
    end

    it "has access to the batch during on_add, perform, and on_success" do
      stubbed_basket = BatchBugBasket.new
      allow(BatchBugBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:perform).and_call_original
      allow(stubbed_basket).to receive(:on_add).and_call_original

      Basket.add("BatchBugBasket", {ticker: :ibm, price: 1234})

      expect($stdout).to have_received(:puts).with([{ticker: :ibm, price: 1234}]).exactly(3).times
    end
  end

  describe ".on_success" do
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

    it "runs on_success after the batch is processed" do
      Basket.add("DummyGroceryBasket", :milk)
      Basket.add("DummyGroceryBasket", :cookies)

      expect($stdout).to have_received(:puts).with("Add milk, cookies to bag")
    end
  end

  describe ".on_failure" do
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

    it "is called when on_add raises an error" do
      stubbed_basket = OnAddErrorBasket.new
      allow(OnAddErrorBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:on_failure).and_call_original

      Basket.add("OnAddErrorBasket", "something")

      expect(stubbed_basket).to have_received(:on_failure)
    end

    it "is called when on_success raises an error and does not clear the queue" do
      stubbed_basket = OnSuccessErrorBasket.new
      allow(OnSuccessErrorBasket).to receive(:new).and_return(stubbed_basket)
      allow(stubbed_basket).to receive(:on_failure).and_call_original

      Basket.add("OnSuccessErrorBasket", "something")

      expect(stubbed_basket).to have_received(:on_failure)
      expect(Basket.queue_collection.length("OnSuccessErrorBasket")).to eq(1)
    end
  end

  describe ".peek" do
    it "returns the data for the given queue" do
      Basket.add("DummyGroceryBasket", "Onions")
      Basket.add("DummyStockBasket", {ticker: "TSLA", value: 0})

      expect(Basket.peek("DummyGroceryBasket")).to eq(["Onions"])
      expect(Basket.peek("DummyStockBasket")).to eq([{ticker: "TSLA", value: 0}])
    end

    it "raises a Basket::NotFoundError if the queue doesn't exist" do
      expect { Basket.peek("NonExistentBasket") }.to raise_error(Basket::BasketNotFoundError)
    end
  end

  describe ".search" do
    it "returns the data wrapped as Elements for a queue" do
      onions = OpenStruct.new(food: "Onions", price: 1.99)
      bananas = OpenStruct.new(food: "Bananas", price: 2.99)
      apples = OpenStruct.new(food: "Apples", price: 0.99)

      Basket.add("DummySearchAndDestroyBasket", onions)
      Basket.add("DummySearchAndDestroyBasket", bananas)
      Basket.add("DummySearchAndDestroyBasket", apples)

      results = Basket.search("DummySearchAndDestroyBasket") do |element|
        element.price < 2.00
      end

      expect(results).to be_a(Array)
    end

    context "when you search on an empty basket" do
      it "raises a Basket::EmptyBasketError" do
        Basket.add("DummyEmptyBasket", "")
        expect(Basket.peek("DummyEmptyBasket")).to eq([])

        expect {
          Basket.search("DummyEmptyBasket") { |element| element.blip = "bloop" }
        }.to raise_error(Basket::EmptyBasketError, /The basket DummyEmptyBasket is empty./)
      end
    end

    context "when you search on a basket that doesn't exist" do
      it "raises a Basket::BasketNotFoundError" do
        expect {
          Basket.search("NonExistentBasket") { |element| element.blip = "bloop" }
        }.to raise_error(Basket::BasketNotFoundError)
      end
    end

    context "when your search returns no results" do
      it "returns an empty array" do
        Basket.add("PlaylistBasket", "The Beatles")
        Basket.add("PlaylistBasket", "The Rolling Stones")
        Basket.add("PlaylistBasket", "The Who")

        results = Basket.search("PlaylistBasket") do |element|
          element == "The Doors"
        end

        expect(results).to eq([])
      end
    end
  end

  describe ".remove" do
    it "removes the data from the given queue" do
      onions = OpenStruct.new(food: "Onions", price: 1.99)
      bananas = OpenStruct.new(food: "Bananas", price: 2.99)
      apples = OpenStruct.new(food: "Apples", price: 0.99)

      Basket.add("DummySearchAndDestroyBasket", onions)
      Basket.add("DummySearchAndDestroyBasket", bananas)
      Basket.add("DummySearchAndDestroyBasket", apples)

      results = Basket.search("DummySearchAndDestroyBasket") do |element|
        element.food == "Onions"
      end

      element_to_delete_id = results.first.id

      deleted_item = Basket.remove("DummySearchAndDestroyBasket", element_to_delete_id)

      expect(deleted_item).to eq(onions)
    end

    context "when the id does not exist" do
      it "raise a Basket::ElementNotFoundError" do
        onions = OpenStruct.new(food: "Onions", price: 1.99)
        Basket.add("DummySearchAndDestroyBasket", onions)
        element_to_delete_id = "non_existent_id"
        expect { Basket.remove("DummySearchAndDestroyBasket", element_to_delete_id) }.to raise_error(Basket::ElementNotFoundError)
      end
    end
  end

  describe ".contents" do
    it "returns the data for the whole basket" do
      Basket.add("DummyGroceryBasket", "Onions")
      Basket.add("DummyStockBasket", {stock: "ORCL", purchased_price: 93.02})

      expect(Basket.contents).to be_a(Hash)
      expect(Basket.contents.keys).to eq(["DummyGroceryBasket", "DummyStockBasket"])
      expect(Basket.contents["DummyGroceryBasket"]).to be_an(Array)
      expect(Basket.contents["DummyGroceryBasket"].first).to be_a(Basket::Element)
      expect(Basket.contents["DummyGroceryBasket"].first.data).to eq("Onions")
    end

    context "when the basket is inspected before anything is done to it" do
      it "returns an empty hash" do
        expect(Basket.contents).to be_a(Hash)
        expect(Basket.contents.keys).to eq([])
      end
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

  describe "concurrent HandleAdd atomicity" do
    before do
      ConcurrencyTrackingBasket.reset_tracking
    end

    it "fires perform exactly once when concurrent threads hit the threshold" do
      # ConcurrencyTrackingBasket has size 5. We add 5 items concurrently.
      # Exactly one perform should fire.
      threads = 5.times.map do |i|
        Thread.new { Basket.add("ConcurrencyTrackingBasket", "item_#{i}") }
      end
      threads.each(&:join)

      expect(ConcurrencyTrackingBasket.perform_count).to eq(1)
    end

    it "fires perform the correct number of times across multiple batches" do
      # Add 20 items with size 5 => expect exactly 4 performs
      # Using threads to add concurrently
      threads = 20.times.map do |i|
        Thread.new { Basket.add("ConcurrencyTrackingBasket", "item_#{i}") }
      end
      threads.each(&:join)

      expect(ConcurrencyTrackingBasket.perform_count).to eq(4)
    end

    it "does not lose items when adding concurrently below threshold" do
      # Add 3 items (below threshold of 5) concurrently
      threads = 3.times.map do |i|
        Thread.new { Basket.add("ConcurrencyTrackingBasket", "item_#{i}") }
      end
      threads.each(&:join)

      expect(ConcurrencyTrackingBasket.perform_count).to eq(0)
      expect(Basket.queue_collection.length("ConcurrencyTrackingBasket")).to eq(3)
    end

    it "clears the queue after perform so subsequent adds start fresh" do
      # Fill one batch of 5
      threads = 5.times.map do |i|
        Thread.new { Basket.add("ConcurrencyTrackingBasket", "item_#{i}") }
      end
      threads.each(&:join)

      expect(ConcurrencyTrackingBasket.perform_count).to eq(1)
      expect(Basket.queue_collection.length("ConcurrencyTrackingBasket")).to eq(0)

      # Add 2 more items -- should not trigger perform
      Basket.add("ConcurrencyTrackingBasket", "extra_1")
      Basket.add("ConcurrencyTrackingBasket", "extra_2")

      expect(ConcurrencyTrackingBasket.perform_count).to eq(1)
      expect(Basket.queue_collection.length("ConcurrencyTrackingBasket")).to eq(2)
    end

    it "does not raise errors under concurrent load" do
      errors = Queue.new

      threads = 50.times.map do |i|
        Thread.new do
          Basket.add("ConcurrencyTrackingBasket", "item_#{i}")
        rescue => e
          errors << e
        end
      end
      threads.each(&:join)

      error_list = []
      error_list << errors.pop until errors.empty?
      expect(error_list).to be_empty
    end
  end

  describe "per-class backend search/remove/peek routing" do
    before do
      Basket.add("MemoryBackendSearchBasket", {name: "alpha", value: 1})
      Basket.add("MemoryBackendSearchBasket", {name: "beta", value: 2})
      Basket.add("MemoryBackendSearchBasket", {name: "gamma", value: 3})
    end

    describe ".peek" do
      it "returns data from the per-class backend" do
        result = Basket.peek("MemoryBackendSearchBasket")
        expect(result.length).to eq(3)
        expect(result.map { |d| d[:name] }).to contain_exactly("alpha", "beta", "gamma")
      end

      it "does not return per-class backend data from the global backend" do
        global_data = Basket.queue_collection.data
        expect(global_data.keys).not_to include("MemoryBackendSearchBasket")
      end

      it "returns data from a redis per-class backend" do
        Basket.add("RedisBackendSearchBasket", {name: "red", value: 10})
        result = Basket.peek("RedisBackendSearchBasket")
        expect(result.length).to eq(1)
        expect(result.first["name"]).to eq("red")
      end
    end

    describe ".search" do
      it "finds items in the per-class backend" do
        results = Basket.search("MemoryBackendSearchBasket") { |d| d[:value] > 1 }
        expect(results.length).to eq(2)
        expect(results.map(&:data).map { |d| d[:name] }).to contain_exactly("beta", "gamma")
      end

      it "returns empty array when no items match in per-class backend" do
        results = Basket.search("MemoryBackendSearchBasket") { |d| d[:value] > 100 }
        expect(results).to eq([])
      end

      it "finds items in a redis per-class backend" do
        Basket.add("RedisBackendSearchBasket", {name: "red", value: 10})
        Basket.add("RedisBackendSearchBasket", {name: "blue", value: 20})
        results = Basket.search("RedisBackendSearchBasket") { |d| d["value"] > 15 }
        expect(results.length).to eq(1)
        expect(results.first.data["name"]).to eq("blue")
      end

      it "does not find per-class backend items in the global backend" do
        Basket.add("DummySearchAndDestroyBasket", {name: "global_item", value: 1})
        global_results = Basket.search("DummySearchAndDestroyBasket") { |d| d[:name] == "alpha" }
        expect(global_results).to eq([])
      end
    end

    describe ".remove" do
      it "removes an item from the per-class backend" do
        results = Basket.search("MemoryBackendSearchBasket") { |d| d[:name] == "beta" }
        id = results.first.id

        removed = Basket.remove("MemoryBackendSearchBasket", id)
        expect(removed[:name]).to eq("beta")

        remaining = Basket.peek("MemoryBackendSearchBasket")
        expect(remaining.length).to eq(2)
        expect(remaining.map { |d| d[:name] }).to contain_exactly("alpha", "gamma")
      end

      it "raises ElementNotFoundError for non-existent id in per-class backend" do
        expect {
          Basket.remove("MemoryBackendSearchBasket", "non_existent_id")
        }.to raise_error(Basket::ElementNotFoundError)
      end

      it "removes an item from a redis per-class backend" do
        Basket.add("RedisBackendSearchBasket", {name: "red", value: 10})
        results = Basket.search("RedisBackendSearchBasket") { |d| d["name"] == "red" }
        id = results.first.id

        removed = Basket.remove("RedisBackendSearchBasket", id)
        expect(removed["name"]).to eq("red")

        remaining = Basket.peek("RedisBackendSearchBasket")
        expect(remaining).to be_empty
      end
    end
  end

  describe "per-class backend configuration" do
    it "accepts a backend option in basket_options" do
      expect(MemoryBackendBasket.basket_options_hash[:backend]).to eq(:memory)
      expect(RedisBackendBasket.basket_options_hash[:backend]).to eq(:redis)
    end

    it "uses the specified backend when a class declares backend: :memory" do
      Basket.add("MemoryBackendBasket", "item1")

      # Data should be stored in the memory backend, not the global default
      # Verify it stored correctly by adding a second item and triggering perform
      Basket.add("MemoryBackendBasket", "item2")

      expect($stdout).to have_received(:puts).with(/memory perform/)
    end

    it "uses the specified backend when a class declares backend: :redis" do
      Basket.add("RedisBackendBasket", "item1")
      Basket.add("RedisBackendBasket", "item2")

      expect($stdout).to have_received(:puts).with(/redis perform/)
    end

    it "falls back to global Basket.config.backend when no per-class backend is set" do
      Basket.add("DefaultBackendBasket", "item1")
      Basket.add("DefaultBackendBasket", "item2")

      expect($stdout).to have_received(:puts).with(/default perform/)
    end

    it "isolates per-class backend data from the global backend" do
      Basket.add("MemoryBackendBasket", "memory_item")
      Basket.add("DefaultBackendBasket", "default_item")

      # The global queue collection should not contain the memory backend basket's data
      global_data = Basket.queue_collection.data
      expect(global_data.keys).to include("DefaultBackendBasket")
      expect(global_data.keys).not_to include("MemoryBackendBasket")
    end

    it "clears per-class backend data when Basket.clear_all is called" do
      Basket.add("MemoryBackendBasket", "item1")
      Basket.add("DefaultBackendBasket", "item1")

      Basket.clear_all

      # After clear_all, both global and per-class backends should be reset
      expect(Basket.contents).to be_a(Hash)
      expect(Basket.contents.keys).to eq([])
    end
  end
end
