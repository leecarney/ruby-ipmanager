
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ip_manager/version"

Gem::Specification.new do |spec|
  spec.name          = "ip_manager"
  spec.version       = IpManager::VERSION
  spec.authors       = ["Skybet"]
  spec.email         = ["infra@skybettingandgaming.com"]
  spec.homepage      = "https://skybet.com"
  spec.summary       = "SBG1 function"
  spec.description   = "SBG1 function - IP manager"
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
