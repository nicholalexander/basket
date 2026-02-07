RSpec.describe Basket::BackendAdapter do
  describe "#data" do
    it "raises an error" do
      expect { subject.data }.to raise_error(NotImplementedError, "must implement data")
    end
  end

  describe "#push" do
    it "raises an error" do
      expect { subject.push("queue", "data") }.to raise_error(NotImplementedError, "must implement push with queue and data params")
    end
  end

  describe "#length" do
    it "raises an error" do
      expect { subject.length("queue") }.to raise_error(NotImplementedError, "must implement length with queue param")
    end
  end

  describe "#read" do
    it "raises an error" do
      expect { subject.read("queue") }.to raise_error(NotImplementedError, "must implement read with queue param")
    end
  end

  describe "#search" do
    it "raises an error" do
      expect { subject.search("queue") {} }.to raise_error(NotImplementedError, "must implement search with queue and block params")
    end
  end

  describe "#remove" do
    it "raises an error" do
      expect { subject.remove("queue", "id") }.to raise_error(NotImplementedError, "must implement remove with queue and id params")
    end
  end

  describe "#clear" do
    it "raises an error" do
      expect { subject.clear("queue") }.to raise_error(NotImplementedError, "must implement clear with queue param")
    end
  end
end
