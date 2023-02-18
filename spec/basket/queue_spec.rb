RSpec.describe Basket::Queue do
  describe "#push" do
    it "adds an element to the specified queue" do
      q = Basket::Queue.new

      q.push("PizzaBasket", "cheese")

      expect(q.data["PizzaBasket"]).to match_array("cheese")
    end

    it "returns the length of the queue" do
      q = Basket::Queue.new

      q.push("InvitationsBasket", "matt")
      length = q.push("InvitationsBasket", "erin")

      expect(length).to eq 2
    end
  end

  describe "#length" do
    it "returns the length of the specified queue" do
      q = Basket::Queue.new

      q.push("RockBasket", {color: :white, value_in_cents: 300})
      q.push("RockBasket", {color: :orange, value_in_cents: 600})
      q.push("RockBasket", {color: :gray, value_incents: 895, for_sale: false})

      expect(q.length("RockBasket")).to eq(3)
    end
  end

  describe "#pop_all" do
    it "returns all the elements in the specified queue" do
      q = Basket::Queue.new

      q.push("PlaylistBasket", {song: "Brown Study", artist: "Vansire"})
      q.push("PlaylistBasket", {song: "Sacred Feathers", artist: "Parra for Cuva, Senoy"})

      data = q.pop_all("PlaylistBasket")

      expect(data.size).to eq(2)

      expect(data.is_a?(Enumerable)).to be true
    end
  end
end
