RSpec.describe Basket::Element do
  describe ".from_queue" do
    context "when the queue item is an Element object" do
      it "returns the Element instance" do
        element = Basket::Element.new("foo")

        expect(Basket::Element.from_queue(element)).to eql(element)
      end
    end

    context "when the queue item is valid json element" do
      context "and the json is a valid element" do
        it "returns a parsed Element instance" do
          element = Basket::Element.new("foo")
          expect(Basket::Element.from_queue(element.to_json)).to eq(element)
        end
      end

      context "and the json isn't a valid element" do
        it "returns a parsed Element instance" do
          element = "{\"foo\":\"bar\"}"

          expect { Basket::Element.from_queue(element) }.to raise_error(Basket::Element::InvalidElement, "both data and id must be present")
        end
      end
    end

    context "when the queue item isn't a valid json object" do
      it "raises an error" do
        element = "{invalid_json: foo}"

        expect { Basket::Element.from_queue(element) }.to raise_error(Basket::Element::InvalidElement, /failed to parse element to json:/)
      end
    end
  end

  describe "#to_json" do
    it "returns json representation of the element object" do
      allow(SecureRandom).to receive(:uuid).and_return("12345")
      element = Basket::Element.new({a: "a", b: "b"})
      parsed_element_json = JSON.parse(element.to_json)

      expect(parsed_element_json).to eq({"id" => "12345", "data" => {"a" => "a", "b" => "b"}})
    end
  end
end
