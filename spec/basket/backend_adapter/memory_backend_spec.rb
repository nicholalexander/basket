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

  describe "#push" do
    context "when data is nil" do
      it "stores nil in the queue" do
        backend = described_class.new
        backend.push("test_queue", nil)
        expect(backend.read("test_queue")).to eq([nil])
        expect(backend.length("test_queue")).to eq(1)
      end
    end
  end

  describe "#length" do
    it "returns the length of the given queue" do
      backend = described_class.new
      backend.push("test_queue", {a: 1})
      backend.push("test_queue", {b: 2})

      expect(backend.length("test_queue")).to eq(2)
    end

    context "when the queue does not exist" do
      it "returns 0" do
        backend = described_class.new
        expect(backend.length("nonexistent_queue")).to eq(0)
      end
    end
  end

  describe "#read" do
    it "returns all the elements in the given queue" do
      backend = described_class.new
      backend.push("test_queue", {a: 1})
      backend.push("test_queue", {b: 2})

      expect(backend.read("test_queue")).to eq([{a: 1}, {b: 2}])
    end

    context "when the queue does not exist" do
      it "returns an empty array" do
        backend = described_class.new
        expect(backend.read("nonexistent_queue")).to eq([])
      end
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

    context "when the queue does not exist" do
      it "returns an empty array" do
        backend = described_class.new
        results = backend.search("nonexistent_queue") { |_| true }
        expect(results).to eq([])
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

  describe "#remove" do
    it "removes the given element from the given queue" do
      element_to_keep = Basket::Element.new({b: 2})
      element_to_delete = Basket::Element.new({a: 1})
      id = element_to_delete.id

      backend = described_class.new

      backend.push("test_queue", element_to_keep)
      backend.push("test_queue", element_to_delete)

      result = backend.remove("test_queue", id)

      expect(result).to eq(element_to_delete)
      expect(backend.read("test_queue")).to eq([element_to_keep])
    end

    context "when the id does not correspond to an element" do
      it "returns nil" do
        element_to_keep = Basket::Element.new({bing: :boop})
        backend = described_class.new
        backend.push("test_queue", element_to_keep)

        result = backend.remove("test_queue", "not an id")
        expect(result).to be_nil
      end
    end

    context "when the queue does not exist" do
      it "returns nil" do
        backend = described_class.new
        result = backend.remove("nonexistent_queue", "some_id")
        expect(result).to be_nil
      end
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

  describe "thread safety" do
    let(:backend) { described_class.new }
    let(:thread_count) { 10 }
    let(:items_per_thread) { 100 }

    describe "concurrent push operations" do
      it "does not lose data when multiple threads push to the same queue" do
        threads = thread_count.times.map do |t|
          Thread.new do
            items_per_thread.times do |i|
              backend.push("test_queue", {thread: t, item: i})
            end
          end
        end
        threads.each(&:join)

        expect(backend.length("test_queue")).to eq(thread_count * items_per_thread)
      end

      it "does not lose data when multiple threads push to different queues" do
        threads = thread_count.times.map do |t|
          Thread.new do
            items_per_thread.times do |i|
              backend.push("queue_#{t}", {item: i})
            end
          end
        end
        threads.each(&:join)

        thread_count.times do |t|
          expect(backend.length("queue_#{t}")).to eq(items_per_thread)
        end
      end
    end

    describe "concurrent read while writing" do
      it "does not raise errors when reading and writing simultaneously" do
        errors = []

        writers = 5.times.map do |t|
          Thread.new do
            50.times do |i|
              backend.push("test_queue", {thread: t, item: i})
            end
          rescue => e
            errors << e
          end
        end

        readers = 5.times.map do
          Thread.new do
            50.times do
              backend.read("test_queue")
              backend.length("test_queue")
            end
          rescue => e
            errors << e
          end
        end

        (writers + readers).each(&:join)

        expect(errors).to be_empty
        expect(backend.length("test_queue")).to eq(250)
      end
    end

    describe "concurrent remove operations" do
      it "does not remove the same element twice" do
        elements = 100.times.map do |i|
          Basket::Element.new({item: i})
        end
        elements.each { |e| backend.push("test_queue", e) }

        removed = Queue.new

        threads = 10.times.map do
          Thread.new do
            elements.each do |e|
              result = backend.remove("test_queue", e.id)
              removed << result unless result.nil?
            end
          end
        end
        threads.each(&:join)

        removed_items = []
        removed_items << removed.pop until removed.empty?

        expect(removed_items.length).to eq(100)
        expect(removed_items.map(&:id).uniq.length).to eq(100)
      end
    end

    describe "concurrent push and clear" do
      it "does not raise errors when pushing and clearing simultaneously" do
        errors = []

        writers = 5.times.map do
          Thread.new do
            50.times { |i| backend.push("test_queue", {item: i}) }
          rescue => e
            errors << e
          end
        end

        clearers = 2.times.map do
          Thread.new do
            20.times { backend.clear("test_queue") }
          rescue => e
            errors << e
          end
        end

        (writers + clearers).each(&:join)

        expect(errors).to be_empty
      end
    end

    describe "concurrent search" do
      it "does not raise errors when searching and writing simultaneously" do
        errors = []

        writers = 5.times.map do |t|
          Thread.new do
            50.times do |i|
              backend.push("test_queue", Basket::Element.new({thread: t, item: i}))
            end
          rescue => e
            errors << e
          end
        end

        searchers = 5.times.map do
          Thread.new do
            50.times do
              backend.search("test_queue") { |data| data[:item] == 1 }
            end
          rescue => e
            errors << e
          end
        end

        (writers + searchers).each(&:join)

        expect(errors).to be_empty
      end
    end
  end
end
