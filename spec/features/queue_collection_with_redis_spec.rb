require "spec_helper"

RSpec.describe "Queue collection with Redis" do
  let(:backend) { Basket::BackendAdapter::RedisBackend }

  describe "#push" do
    it "adds the element to the queue" do
      q = Basket::QueueCollection.new(backend)
      q.push("PizzaBasket", "cheese")

      queue_element = q.read("PizzaBasket").first

      expect(queue_element).to eq("cheese")
    end
  end

  describe "#length" do
    it "returns the length of the queue" do
      q = Basket::QueueCollection.new(backend)

      q.push("InvitationsBasket", "matt")
      length = q.push("InvitationsBasket", "erin")

      expect(length).to eq 2
    end
  end

  describe "#read" do
    it "returns the elements in the queue" do
      q = Basket::QueueCollection.new(backend)

      q.push("PlaylistBasket", {song: "Brown Study", artist: "Vansire"})
      q.push("PlaylistBasket", {song: "Sacred Feathers", artist: "Parra for Cuva, Senoy"})

      data = q.read("PlaylistBasket")

      expect(data.size).to eq(2)
      expect(data.is_a?(Enumerable)).to be true
      expect(data).to match_array([{"song" => "Brown Study", "artist" => "Vansire"},
        {"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"}])
    end
  end

  describe "#search" do
    let(:q) { Basket::QueueCollection.new(backend) }

    before do
      q.push("PlaylistBasket", {song: "Brown Study", artist: "Vansire"})
      q.push("PlaylistBasket", {song: "Sacred Feathers", artist: "Parra for Cuva, Senoy"})
      q.push("PlaylistBasket", {song: "Lavender", artist: "BadBadNotGood"})
    end

    it "returns and array of elements in the specified queue that match the query" do
      query_proc = proc { |element| element["artist"] == "Vansire" }

      results = q.search("PlaylistBasket", query_proc)

      expect(results.size).to eq(1)

      expect(results).to be_a(Array)
      expect(results.first).to be_a(Basket::Element)
    end
  end

  describe "#delete" do
    let(:q) { Basket::QueueCollection.new(backend) }

    it "deletes the specified element from the specified queue" do
      q.push("PlaylistBasket", {song: "Brown Study", artist: "Vansire"})
      q.push("PlaylistBasket", {song: "Sacred Feathers", artist: "Parra for Cuva, Senoy"})

      query_proc = proc { |element| element["artist"] == "Vansire" }

      element_to_delete = q.search("PlaylistBasket", query_proc).first

      deleted_element = q.delete("PlaylistBasket", element_to_delete.id)

      expect(q.length("PlaylistBasket")).to eq(1)
      expect(element_to_delete.data).to eq(deleted_element)
      expect(q.read("PlaylistBasket")).to eq([{"song" => "Sacred Feathers", "artist" => "Parra for Cuva, Senoy"}])
    end
  end
end
