RSpec.describe Basket::BackendAdapter do
  describe "#data" do
    it "raises an error" do
      expect { subject.data }.to raise_error("must implement data")
    end
  end

  describe "#push" do
    it "raises an error" do
      expect { subject.push("queue", "data") }.to raise_error("must implement push with queue and data params")
    end
  end

  describe "#length" do
    it "raises an error" do
      expect { subject.length("queue") }.to raise_error("must implement length with queue param")
    end
  end

  describe "#read" do
    it "raises an error" do
      expect { subject.read("queue") }.to raise_error("must implement read with queue param")
    end
  end

  describe "#clear" do
    it "raises an error" do
      expect { subject.clear("queue") }.to raise_error("must implement clear with queue param")
    end
  end
end
