RSpec.describe Basket::QueueCollection do
  around(:each) do |example|
    [:memory, :redis].each do |backend|
      Basket.config.backend = backend
      example.run
    end

    # reset to default.
    Basket.config.backend = :memory
  end

  describe "#push" do
    it "adds an element to the specified queue" do
      q = Basket::QueueCollection.new

      q.push("PizzaBasket", "cheese")

      queue_element = q.read("PizzaBasket").first

      expect(queue_element).to eq("cheese")
    end

    it "returns the length of the queue" do
      q = Basket::QueueCollection.new

      q.push("InvitationsBasket", "matt")
      length = q.push("InvitationsBasket", "erin")

      expect(length).to eq 2
    end
  end

  describe "#length" do
    it "returns the length of the specified queue" do
      q = Basket::QueueCollection.new

      q.push("RockBasket", {"color" => :white, "value_in_cents" => 300})
      q.push("RockBasket", {"color" => :orange, "value_in_cents" => 600})
      q.push("RockBasket", {"color" => :gray, "value_in_cents" => 895, "for_sale" => false})

      expect(q.length("RockBasket")).to eq(3)
    end
  end

  describe "#read" do
    it "returns the elements in the specified queue" do
      q = Basket::QueueCollection.new

      q.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      q.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})

      data = q.read("PlaylistBasket")

      expect(data.size).to eq(2)
      expect(data.is_a?(Enumerable)).to be true
      expect(data).to match_array([{"song" => "Brown Study", "artist" => "Vansire"},
        {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"}])
    end

    it "preserves the data in the queue" do
      q = Basket::QueueCollection.new

      q.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      q.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})

      q.read("PlaylistBasket")

      expect(q.length("PlaylistBasket")).to eq(2)
    end
  end

  describe "#search" do
    it "returns and array of elements in the specified queue that match the query" do
      q = Basket::QueueCollection.new

      q.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      q.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})
      q.push("PlaylistBasket", {"song" => "Lavender", "artist" => "BadBadNotGood"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      results = q.search("PlaylistBasket", query_proc)

      expect(results.size).to eq(1)

      expect(results).to be_a(Array)
      expect(results.first).to be_a(Basket::Element)
    end

    it "returns the correct element" do
      q = Basket::QueueCollection.new

      q.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      q.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})
      q.push("PlaylistBasket", {"song" => "Lavender", "artist" => "BadBadNotGood"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      results = q.search("PlaylistBasket", query_proc)

      element = results.first

      expect(element.id).to_not be_nil
      expect(element.data).to eq({"song" => "Brown Study", "artist" => "Vansire"})
    end

    it "does not alter the queue" do
      q = Basket::QueueCollection.new

      q.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      q.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})
      q.push("PlaylistBasket", {"song" => "Lavender", "artist" => "BadBadNotGood"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      q_before_search = q.read("PlaylistBasket")

      q.search("PlaylistBasket", query_proc)

      q_after_search = q.read("PlaylistBasket")

      expect(q_before_search).to eq(q_after_search)
      expect(q.length("PlaylistBasket")).to eq(3)
    end
  end

  describe "#remove" do
    it "removes the specified element from the specified queue" do
      q = Basket::QueueCollection.new

      q.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      q.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      element_to_delete = q.search("PlaylistBasket", query_proc).first

      deleted_element = q.remove("PlaylistBasket", element_to_delete.id)

      expect(q.length("PlaylistBasket")).to eq(1)
      expect(element_to_delete.data).to eq(deleted_element)
      expect(q.read("PlaylistBasket")).to eq([{"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"}])
    end
  end

  describe "#clear" do
    it "clears the specified queue" do
      q = Basket::QueueCollection.new

      q.push("DummyStockBasket", {"symbol" => "AAPL", "price" => 100.00})
      q.push("DummyStockBasket", {"symbol" => "GOOG", "price" => 200.00})

      q.clear("DummyStockBasket")

      expect(q.read("DummyStockBasket")).to eq([])
    end
  end
end
