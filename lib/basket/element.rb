require "securerandom"

module Basket
  class Element
    class InvalidElement < StandardError; end

    attr_reader :data, :id

    def self.from_queue(element)
      if element.is_a?(Element)
        element
      else
        parsed_element = JSON.parse(element)
        new(parsed_element["data"], parsed_element["id"])
      end
    rescue JSON::ParserError => e
      raise InvalidElement, "failed to parse element to json: #{e.message} "
    end

    def initialize(data, id = SecureRandom.uuid)
      raise InvalidElement, "both data and id must be present" unless data && id

      @data = data
      @id = id
    end

    def to_h
      {data: data, id: id}
    end

    def to_json(*)
      to_h.to_json
    end

    def ==(other)
      to_h == other.to_h
    end
  end
end
