# -*- encoding: utf-8 -*-
# stub: simplecov-json 0.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "simplecov-json".freeze
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Vicent Llongo".freeze]
  s.date = "2020-10-26"
  s.description = "JSON formatter for SimpleCov code coverage tool for ruby 1.9+".freeze
  s.email = ["villosil@gmail.com".freeze]
  s.homepage = "https://github.com/vicentllongo/simplecov-json".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "JSON formatter for SimpleCov code coverage tool for ruby 1.9+".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
