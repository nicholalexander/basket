RSpec.describe Basket::BackendAdapter::HashBackend do
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
