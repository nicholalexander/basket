RSpec.describe Basket::Configuration do
  describe "defaults" do
    it "has the correct defaults" do
      configuration = Basket::Configuration.new

      expect(configuration.redis_host).to eq("127.0.0.1")
      expect(configuration.redis_port).to eq(6379)
      expect(configuration.redis_db).to eq(15)
      expect(configuration.backend).to eq(Basket::BackendAdapter::HashBackend)
      expect(configuration.namespace).to eq(:basket)
    end
  end

  describe "changing defaults" do
    it "allows you to change all the defaults" do
      configuration = Basket::Configuration.new
      configuration.redis_host = "something else"
      configuration.redis_port = 10
      configuration.redis_db = 100_000
      configuration.backend = :redis
      configuration.namespace = :something_else

      expect(configuration.redis_host).to eq("something else")
      expect(configuration.redis_port).to eq(10)
      expect(configuration.redis_db).to eq(100_000)
      expect(configuration.backend).to eq(Basket::BackendAdapter::RedisBackend)
      expect(configuration.namespace).to eq(:something_else)
    end
  end

  describe "#backend=" do
    it "sets the hash backend when :hash is passed" do
      configuration = Basket::Configuration.new
      configuration.backend = :hash
      expect(configuration.backend).to eq(Basket::BackendAdapter::HashBackend)
    end

    it "sets the redis backend when :redis is passed" do
      configuration = Basket::Configuration.new
      configuration.backend = :redis
      expect(configuration.backend).to eq(Basket::BackendAdapter::RedisBackend)
    end

    it "raises a configuration error when you pass an unknown backend" do
      configuration = Basket::Configuration.new
      expect { configuration.backend = :bloop }.to raise_error(Basket::Error, /Unknown Backend/)
    end
  end
end
