RSpec.describe Basket::BackendAdapter::RedisBackend do
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

      expect(result).to eq(1)
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

  describe "#pop_all" do
    it "returns all the elements in the given queue" do
      backend = described_class.new
      backend.push("test_queue", {a: 1})
      backend.push("test_queue", {b: 2})

      expect(backend.pop_all("test_queue")).to eq([{a: 1}, {b: 2}])
    end
  end

  describe "client" do
    it "returns the redis client" do
      expect(described_class.new.client).to be_a(Redis::Namespace)
    end

    it "configures the client based on the Basket::Configuration" do
      expect(described_class.new.client.redis.host).to eq(Basket.config.redis_host)
      expect(described_class.new.client.redis.port).to eq(Basket.config.redis_port)
      expect(described_class.new.client.redis.db).to eq(Basket.config.redis_db)
      expect(described_class.new.client.namespace).to eq(Basket.config.namespace)
    end
  end
end
