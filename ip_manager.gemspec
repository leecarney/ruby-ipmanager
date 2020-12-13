
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ip_manager/version"

Gem::Specification.new do |spec|
  spec.name          = "ip_manager"
  spec.version       = IpManager::VERSION
  spec.authors       = ["LeeC"]
  spec.email         = ["edited@edit.com"]
  spec.homepage      = "https://github.com"
  spec.summary       = "MyIP function"
  spec.description   = "MyIP function - IP manager"
  spec.license       = "Nonstandard"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  #spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
