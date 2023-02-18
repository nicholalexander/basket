# frozen_string_literal: true

require_relative "basket/batcher"
require_relative "basket/hash_backend"
require_relative "basket/queue"
require_relative "basket/version"

module Basket
  class Error < StandardError; end

  def self.add(queue, data)
    queue_length = Basket::Queue.push(queue, data)
    queue_class = queue.constantize.new
    return unless queue_length == queue_class.batcher.options.queue_length

    queue_class.perform
  end
end
