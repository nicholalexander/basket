# frozen_string_literal: true

require_relative "basket/batcher"
require_relative "basket/hash_backend"
require_relative "basket/queue"
require_relative "basket/version"

module Basket
  class Error < StandardError; end

  def self.config
    @config ||= {queue: Basket::Queue.new}
  end

  def self.contents
    @config[:queue].data
  end

  def self.add(queue, data)
    queue_length = @config[:queue].push(queue, data)
    queue_class = Object.const_get(queue)
    queue_instance = queue_class.new

    queue_instance.define_singleton_method(:element) { data }
    queue_instance.on_add

    return unless queue_length == queue_class.basket_options_hash[:size]

    queue_instance.perform
    queue_instance.on_success
  rescue => e
    queue_instance.define_singleton_method(:error) { e }
    queue_instance.on_failure
  end

  def self.clear_all
    unless @config.nil?
      @config[:queue] = Basket::Queue.new
    end
  end
end
