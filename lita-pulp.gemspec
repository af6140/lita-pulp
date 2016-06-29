Gem::Specification.new do |spec|
  spec.name          = "lita-pulp"
  spec.version       = "0.1.0"
  spec.authors       = ["Wang, Dawei"]
  spec.email         = ["daweiwang.gatekeeper@gmail.com"]
  spec.description   = "Lita bot for pulp server"
  spec.summary       = "Lita bot for pulp server operation, like list repositories and search rpm or puppet modules."
  spec.homepage      = "https://github.com/af6140/lita-pulp.git"
  spec.license       = "Apache-2.0"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  spec.add_runtime_dependency "runcible"
  spec.add_runtime_dependency "lita-keyword-arguments"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
end
