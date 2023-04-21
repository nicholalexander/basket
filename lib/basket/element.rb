require "securerandom"

module Basket
  class Element
    class InvalidElement < StandardError; end

    attr_reader :data, :id

    def self.from_queue(element)
      if element.is_a?(Element)
        element
      elsif element.is_a?(Hash)
        new(element["data"], element["id"])
      else
        raise InvalidElement, "element must be a hash or a Basket::Element"
      end
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
