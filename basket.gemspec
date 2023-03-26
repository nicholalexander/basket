# frozen_string_literal: true

require_relative "lib/basket/version"

Gem::Specification.new do |spec|
  spec.name = "basket"
  spec.version = Basket::VERSION
  spec.authors = ["nichol alexander", "alec clarke"]
  spec.email = ["nichol.alexander@gmail.com", "alec.clarke.dev@gmail.com"]

  spec.summary = "Wait until you have a bunch of things, then do something."
  spec.description = "A simple way of accumulating things and then acting on them."
  spec.homepage = "https://github.com/nicholalexander/basket"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nicholalexander/basket"
  spec.metadata["changelog_uri"] = "https://github.com/nicholalexander/basket/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"
  spec.add_dependency "redis-namespace"


  spec.add_development_dependency "mock_redis"
end
