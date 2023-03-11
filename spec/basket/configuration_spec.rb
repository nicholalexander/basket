RSpec.describe Basket::Configuration do
  describe "defaults" do
    it "has the correct defaults" do

      configuration = Basket::Configuration.new

      expect(configuration.redis_host).to eq("127.0.0.1")
      expect(configuration.redis_port).to eq(6379)
      expect(configuration.redis_db).to eq(15)
    end
  end
end
