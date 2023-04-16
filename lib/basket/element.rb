require "securerandom"

module Basket
  class Element
    attr_reader :data, :id

    def self.from_queue(element)
      if element.is_a?(Element)
        element
      else
        parsed_element = JSON.parse(element)

        new(parsed_element["data"], parsed_element["id"])
      end
    end

    def initialize(data, id = SecureRandom.uuid)
      @data = data
      @id = id
    end

    def to_json(*)
      {data: data, id: id}.to_json
    end
  end
end
