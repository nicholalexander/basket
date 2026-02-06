RSpec.shared_examples "backend adapter" do |klass|
  describe "abstract methods" do
    it "does not raise an error when calling an abstract method" do
      backend = klass.new
      expect { backend.data }.not_to raise_error
      expect { backend.push("test_queue", {a: 1}) }.not_to raise_error
      expect { backend.length("test_queue") }.not_to raise_error
      expect { backend.read("test_queue") }.not_to raise_error
      expect { backend.search("test_queue") { |_| true } }.not_to raise_error
      expect { backend.remove("test_queue", "nonexistent_id") }.not_to raise_error
      expect { backend.clear("test_queue") }.not_to raise_error
    end
  end
end
