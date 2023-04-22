RSpec.describe Basket::BackendAdapter::RedisBackend do
  describe "#data" do
    it "returns all the basket entries" do
      backend = described_class.new
      backend.push("test_queue_1", {"a" => 1})
      backend.push("test_queue_1", {"a" => 2})
      backend.push("test_queue_2", {"b" => 1})

      expect(backend.data).to eq({
        "test_queue_1" => [{"a" => 1}, {"a" => 2}],
        "test_queue_2" => [{"b" => 1}]
      })
    end
  end

  describe "#search" do
    it "returns all the elements that match the search query" do
      backend = described_class.new
      backend.push("test_queue", Basket::Element.new({a: 1}))
      backend.push("test_queue", Basket::Element.new({b: 2}))

      results = backend.search("test_queue") do |element_data|
        element_data["a"] == 1
      end

      expect(results).to be_a(Array)

      result = results.first

      expect(result).to be_a(Hash)
      expect(result["data"]).to eq({"a" => 1})
    end

    context "when there are multiple matches" do
      it "returns all of them" do
        backend = described_class.new
        backend.push("test_queue", Basket::Element.new({a: 1, c: 2}))
        backend.push("test_queue", Basket::Element.new({b: 2}))
        backend.push("test_queue", Basket::Element.new({a: 1, c: 3}))

        results = backend.search("test_queue") do |element_data|
          element_data["a"] == 1
        end

        expect(results.size).to eq(2)
        expect(results[0]["data"]).to eq({"a" => 1, "c" => 2})
        expect(results[1]["data"]).to eq({"a" => 1, "c" => 3})
      end
    end
  end

  describe "#remove" do
    it "removes the element from the redis queue" do
      backend = described_class.new
      element_1 = Basket::Element.new({a: 1})
      element_2 = Basket::Element.new({b: 2})

      backend.push("test_queue", element_1)
      backend.push("test_queue", element_2)

      result = backend.remove("test_queue", element_2.id)

      expect(result).to eq(JSON.parse(element_2.to_json))
    end

    context "when the id does not correspond to an element" do
      it "returns nil" do
        backend = described_class.new
        element_1 = Basket::Element.new({a: 1})
        element_2 = Basket::Element.new({b: 2})

        backend.push("test_queue", element_1)
        backend.push("test_queue", element_2)

        result = backend.remove("test_queue", "invalid_id")

        expect(result).to be_nil
      end
    end
  end

  describe "#push" do
    it "pushes an item into the given queue" do
      result = described_class.new.push("test_queue", {"a" => 1})

      expect(result).to eq(1)
    end
  end

  describe "#length" do
    it "returns the length of the given queue" do
      backend = described_class.new
      backend.push("test_queue", {"a" => 1})
      backend.push("test_queue", {"b" => 2})

      expect(backend.length("test_queue")).to eq(2)
    end
  end

  describe "client" do
    it "returns the redis client" do
      expect(described_class.new.client).to be_a(Redis::Namespace)
    end

    context "when the configuration is to use host and port" do
      it "configures the client based on the Basket::Configuration" do
        expect(described_class.new.client.redis.host).to eq(Basket.config.redis_host)
        expect(described_class.new.client.redis.port).to eq(Basket.config.redis_port)
        expect(described_class.new.client.redis.db).to eq(Basket.config.redis_db)
        expect(described_class.new.client.namespace).to eq(Basket.config.namespace)
      end
    end

    context "when the configuration is to use a redis url" do
      it "configures the client based on the Basket::Configuration" do
        Basket.config.redis_url = "redis://:p4ssw0rd@10.0.1.1:6380/15"
        expect(described_class.new.client.redis.options[:url]).to eq(Basket.config.redis_url)
        Basket.config.redis_url = nil
      end
    end
  end

  describe "it implements the backend adapter interface" do
    include_examples "backend adapter", described_class
  end
end
