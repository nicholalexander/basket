RSpec.describe Basket::BackendAdapter::MemoryBackend do
  describe "#data" do
    it "returns all the basket entries" do
      backend = described_class.new
      backend.push("test_queue_1", {a: 1})
      backend.push("test_queue_1", {a: 2})
      backend.push("test_queue_2", {b: 1})

      expect(backend.data).to eq({
        "test_queue_1" => [{a: 1}, {a: 2}],
        "test_queue_2" => [{b: 1}]
      })
    end
  end

  describe "#push" do
    it "pushes an item into the given queue" do
      result = described_class.new.push("test_queue", {a: 1})

      expect(result).to eq([{a: 1}])
    end
  end

  describe "#length" do
    it "returns the length of the given queue" do
      backend = described_class.new
      backend.push("test_queue", {a: 1})
      backend.push("test_queue", {b: 2})

      expect(backend.length("test_queue")).to eq(2)
    end
  end

  describe "#read" do
    it "returns all the elements in the given queue" do
      backend = described_class.new
      backend.push("test_queue", {a: 1})
      backend.push("test_queue", {b: 2})

      expect(backend.read("test_queue")).to eq([{a: 1}, {b: 2}])
    end
  end

  describe "#search" do
    it "returns all the elements that match the search query" do
      backend = described_class.new
      backend.push("test_queue", Basket::Element.new({a: 1}))
      backend.push("test_queue", Basket::Element.new({b: 2}))

      results = backend.search("test_queue") do |query|
        query[:a] == 1
      end

      expect(results).to be_a(Array)
      expect(results.first).to be_an(Basket::Element)

      result = results.first

      expect(result.data).to eq({a: 1})
    end

    context "when there are multiple matches" do
      it "returns all of them" do
        backend = described_class.new
        backend.push("test_queue", Basket::Element.new({a: 1}))
        backend.push("test_queue", Basket::Element.new({b: 2}))
        backend.push("test_queue", Basket::Element.new({a: 1}))

        results = backend.search("test_queue") do |query|
          query[:a] == 1
        end

        expect(results.map(&:data)).to eq([{a: 1}, {a: 1}])
      end
    end

    context "when the queue contains objects" do
      it "selects the objects" do
        robin_egg = OpenStruct.new(name: "robin", color: "blue")
        organic_chicken_egg = OpenStruct.new(name: "chicken", color: "brown")
        blue_jay = OpenStruct.new(name: "jay", color: "blue")
        supermarket_chicken_egg = OpenStruct.new(name: "chicken", color: "white")

        backend = described_class.new

        backend.push("egg_queue", Basket::Element.new(robin_egg))
        backend.push("egg_queue", Basket::Element.new(organic_chicken_egg))
        backend.push("egg_queue", Basket::Element.new(blue_jay))
        backend.push("egg_queue", Basket::Element.new(supermarket_chicken_egg))

        results = backend.search("egg_queue") do |query|
          query.color == "blue"
        end

        expect(results.map(&:data).map(&:name)).to eq(["robin", "jay"])
      end
    end
  end

  describe "#delete" do
    it "deletes the given element from the given queue" do
      element_to_keep = Basket::Element.new({b: 2})
      element_to_delete = Basket::Element.new({a: 1})
      id = element_to_delete.id

      backend = described_class.new

      backend.push("test_queue", element_to_keep)
      backend.push("test_queue", element_to_delete)

      result = backend.delete("test_queue", id)

      expect(result).to eq(element_to_delete)
      expect(backend.read("test_queue")).to eq([element_to_keep])
    end
  end

  describe "#clear" do
    it "clears the given queue" do
      backend = described_class.new
      backend.push("test_queue", {a: 1})
      backend.push("test_queue", {b: 2})

      backend.clear("test_queue")

      expect(backend.read("test_queue")).to eq([])
    end
  end

  describe "it implements the backend adapter interface" do
    include_examples "backend adapter", described_class
  end
end
