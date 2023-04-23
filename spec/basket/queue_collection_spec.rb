RSpec.describe Basket::QueueCollection do
  describe "it implements the queue collection with a redis backend" do
    include_examples "for QueueCollection", Basket::BackendAdapter::RedisBackend
  end

  describe "it implements the queue collection with a memory backend" do
    include_examples "for QueueCollection", Basket::BackendAdapter::MemoryBackend
  end
end
