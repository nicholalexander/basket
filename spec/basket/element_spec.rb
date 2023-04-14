RSpec.describe Basket::Element do
  describe "#to_json" do
    it "returns json representation of the element object" do
      allow(SecureRandom).to receive(:uuid).and_return("12345")
      element = Basket::Element.new({a: "a", b: "b"})
      parsed_element_json = JSON.parse(element.to_json)

      expect(parsed_element_json).to eq({"id" => "12345", "data" => {"a" => "a", "b" => "b"}})
    end
  end
end
