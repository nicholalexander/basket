# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in basket.gemspec
gemspec

gem "pry"
gem "guard"
gem "guard-rspec", require: false
gem "guard-standardrb", require: false
gem "mocktail"
gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "simplecov", require: false, group: :test
gem "simplecov-json", require: false, group: :test
gem "standard", "~> 1.30"

# Type checking gems require Ruby >= 3.2 due to activesupport/minitest dependency
group :type_check do
  gem "steep", require: false
  gem "rbs", require: false
end
