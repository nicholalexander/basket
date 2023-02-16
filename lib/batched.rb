# frozen_string_literal: true

require_relative "batched/version"

module Batched
  class Error < StandardError; end

  def self.add(queue, data)
    queue_length = Batched::Queue.push(queue, data)
    queue_class = queue.constantize.new
    if queue_length == queue_class.batcher.options.queue_length
      queue_class.perform
    end
  end
end
