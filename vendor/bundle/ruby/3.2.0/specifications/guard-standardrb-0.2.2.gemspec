# -*- encoding: utf-8 -*-
# stub: guard-standardrb 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "guard-standardrb".freeze
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/JodyVanden/guard-standardrb", "homepage_uri" => "https://github.com/JodyVanden/guard-standardrb", "source_code_uri" => "https://github.com/JodyVanden/guard-standardrb" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jody Vandenschrick".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-07-02"
  s.email = ["jody.vanden@gmail.com".freeze]
  s.homepage = "https://github.com/JodyVanden/guard-standardrb".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "add a plugin to guard to work with standardrb.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<guard>.freeze, [">= 2.0.0"])
  s.add_runtime_dependency(%q<guard-compat>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<standardrb>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.1"])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
end
