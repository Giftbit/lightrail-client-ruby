# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lightrail_client/version"

Gem::Specification.new do |spec|
  spec.name = "lightrail_client"
  spec.version = Lightrail::VERSION
  spec.authors = ["Lightrail"]
  spec.email = ["tana.j@lightrail.com"]

  spec.summary = "A client library for the Lightrail API"
  spec.description = "Acquire and retain customers using account credits, gift cards, promotions, and points."
  spec.homepage = "https://www.lightrail.com/"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) {|f| File.basename(f)}
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.5"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "pry-byebug", "~>3.6"
  spec.add_development_dependency "dotenv", "~> 2.5"

  spec.add_runtime_dependency "faraday", "~>0.15"
  spec.add_runtime_dependency "json", "~>1.8"
  spec.add_runtime_dependency "openssl", "~>2.1"
  spec.add_runtime_dependency "jwt", "~>2.1"
end
