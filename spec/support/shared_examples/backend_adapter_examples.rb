RSpec.shared_examples "backend adapter" do |klass|
  describe "abstract methods" do
    it "does not raise an error when calling an abstract method" do
      backend = klass.new
      expect { backend.data }.not_to raise_error
      expect { backend.push("test_queue", {a: 1}) }.not_to raise_error
      expect { backend.length("test_queue") }.not_to raise_error
      expect { backend.read("test_queue") }.not_to raise_error
      expect { backend.clear("test_queue") }.not_to raise_error
    end

    it "supports search on a queue with elements" do
      backend = klass.new
      backend.push("search_queue", Basket::Element.new({a: 1}))
      expect { backend.search("search_queue") { |_| true } }.not_to raise_error
    end

    it "supports remove on a queue with elements" do
      backend = klass.new
      backend.push("remove_queue", Basket::Element.new({a: 1}))
      expect { backend.remove("remove_queue", "nonexistent_id") }.not_to raise_error
    end
  end
end
