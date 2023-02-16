# frozen_string_literal: true

require_relative "lib/batched/version"

Gem::Specification.new do |spec|
  spec.name = "batched"
  spec.version = Batched::VERSION
  spec.authors = ["nichol alexander"]
  spec.email = ["nichol.alexander@gmail.com "]

  spec.summary = "Wait until you have a bunch of things, then do something."
  spec.description = "This is a longer description."
  spec.homepage = "https://github.com/nicholalexander/batched"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nicholalexander/batched"
  spec.metadata["changelog_uri"] = "https://github.com/nicholalexander/batched/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
