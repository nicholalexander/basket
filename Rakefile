# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

if RUBY_VERSION < "3.4"
  require "standard/rake"
  task default: %i[spec standard:fix]
else
  task default: :spec
end
