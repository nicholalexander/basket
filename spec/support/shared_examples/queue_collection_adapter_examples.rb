require "spec_helper"

RSpec.shared_examples "for QueueCollection" do |backend|
  let(:queue_collection) { Basket::QueueCollection.new(backend) }

  describe "#push" do
    it "adds an element to the specified queue" do
      queue_collection.push("PizzaBasket", "cheese")

      queue_element = queue_collection.read("PizzaBasket").first

      expect(queue_element).to eq("cheese")
    end

    it "returns the length of the queue" do
      queue_collection.push("InvitationsBasket", "matt")
      length = queue_collection.push("InvitationsBasket", "erin")

      expect(length).to eq 2
    end
  end
  describe "#length" do
    it "returns the length of the specified queue" do
      queue_collection.push("RockBasket", {"color" => :white, "value_in_cents" => 300})
      queue_collection.push("RockBasket", {"color" => :orange, "value_in_cents" => 600})
      queue_collection.push("RockBasket", {"color" => :gray, "value_in_cents" => 895, "for_sale" => false})

      expect(queue_collection.length("RockBasket")).to eq(3)
    end
  end

  describe "#read" do
    it "returns the elements in the specified queue" do
      queue_collection.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      queue_collection.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})

      data = queue_collection.read("PlaylistBasket")

      expect(data.size).to eq(2)
      expect(data.is_a?(Enumerable)).to be true
      expect(data).to match_array([{"song" => "Brown Study", "artist" => "Vansire"},
        {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"}])
    end

    it "preserves the data in the queue" do
      queue_collection.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      queue_collection.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})

      queue_collection.read("PlaylistBasket")

      expect(queue_collection.length("PlaylistBasket")).to eq(2)
    end
  end

  describe "#search" do
    it "returns and array of elements in the specified queue that match the query" do
      queue_collection.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      queue_collection.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})
      queue_collection.push("PlaylistBasket", {"song" => "Lavender", "artist" => "BadBadNotGood"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      results = queue_collection.search("PlaylistBasket", query_proc)

      expect(results.size).to eq(1)

      expect(results).to be_a(Array)
      expect(results.first).to be_a(Basket::Element)
    end

    it "returns the correct element" do
      queue_collection.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      queue_collection.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})
      queue_collection.push("PlaylistBasket", {"song" => "Lavender", "artist" => "BadBadNotGood"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      results = queue_collection.search("PlaylistBasket", query_proc)

      element = results.first

      expect(element.id).to_not be_nil
      expect(element.data).to eq({"song" => "Brown Study", "artist" => "Vansire"})
    end

    it "does not alter the queue" do
      queue_collection.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      queue_collection.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})
      queue_collection.push("PlaylistBasket", {"song" => "Lavender", "artist" => "BadBadNotGood"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      q_before_search = queue_collection.read("PlaylistBasket")

      queue_collection.search("PlaylistBasket", query_proc)

      q_after_search = queue_collection.read("PlaylistBasket")

      expect(q_before_search).to eq(q_after_search)
      expect(queue_collection.length("PlaylistBasket")).to eq(3)
    end
  end

  describe "#remove" do
    it "removes the specified element from the specified queue" do
      queue_collection.push("PlaylistBasket", {"song" => "Brown Study", "artist" => "Vansire"})
      queue_collection.push("PlaylistBasket", {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      element_to_delete = queue_collection.search("PlaylistBasket", query_proc).first

      deleted_element = queue_collection.remove("PlaylistBasket", element_to_delete.id)

      expect(queue_collection.length("PlaylistBasket")).to eq(1)
      expect(element_to_delete.data).to eq(deleted_element)
      expect(queue_collection.read("PlaylistBasket")).to eq([{"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"}])
    end
  end

  describe "#clear" do
    it "clears the specified queue" do
      queue_collection.push("DummyStockBasket", {"symbol" => "AAPL", "price" => 100.00})
      queue_collection.push("DummyStockBasket", {"symbol" => "GOOG", "price" => 200.00})

      queue_collection.clear("DummyStockBasket")

      expect(queue_collection.read("DummyStockBasket")).to eq([])
    end
  end
end
