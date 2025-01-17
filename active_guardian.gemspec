
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_guardian/version"

Gem::Specification.new do |spec|
  spec.name          = "active_guardian"
  spec.version       = ActiveGuardian::VERSION
  spec.authors       = ["Jon Christopher"]
  spec.email         = ["joncirca@icloud.com"]

  spec.summary       = 'Overrides Active Record default migrations to prevent accidental or malicious data loss'
  spec.description   = 'ActiveGuardian is a gem that customizes Active Record migrations in Ruby on Rails to enforce strict database-level constraints, focusing on column immutability and user role restrictions. It automatically generates PostgreSQL triggers for read-only columns and sets up two database users: one with full migration capabilities and another with restricted permissions for safer operations. Note: This gem is specifically designed to work with PostgreSQL.'
  spec.homepage      = "https://github.com/jondavidchristopher/active_guardian"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/jondavidchristopher/active_guardian"
    spec.metadata["changelog_uri"] = "https://github.com/jondavidchristopher/active_guardian/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_dependency 'activerecord', '>= 6.0'
end

