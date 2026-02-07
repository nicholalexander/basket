# frozen_string_literal: true

require "securerandom"

module Basket
  # Wraps data stored in a queue with a unique identifier.
  class Element
    # Raised when an element cannot be constructed from invalid input.
    class InvalidElement < Basket::Error; end

    # @return [Object] the stored data
    attr_reader :data

    # @return [String] the unique element identifier
    attr_reader :id

    # Constructs an Element from a raw queue entry (Element or Hash).
    # @param element [Basket::Element, Hash] the raw element
    # @return [Basket::Element]
    # @raise [InvalidElement] if the element is not a Hash or Element
    # @raise [InvalidElement] if a Hash is missing "data" or "id" keys
    def self.from_queue(element)
      if element.is_a?(Element)
        element
      elsif element.is_a?(Hash)
        new(element["data"], element["id"])
      else
        raise InvalidElement, "element must be a hash or a Basket::Element"
      end
    end

    # @param data [Object] the data to store
    # @param id [String] unique identifier (defaults to a UUID)
    # @raise [InvalidElement] if data or id is nil
    def initialize(data, id = SecureRandom.uuid)
      raise InvalidElement, "both data and id must be present" unless data && id

      @data = data
      @id = id
    end

    # Returns a hash representation of the element.
    # @return [Hash{Symbol => Object}]
    def to_h
      {data: data, id: id}
    end

    # Returns a JSON representation of the element.
    # @return [String]
    def to_json(*)
      to_h.to_json
    end

    # Compares two elements by their hash representation.
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      return false unless other.respond_to?(:to_h)
      to_h == other.to_h
    end
  end
end
