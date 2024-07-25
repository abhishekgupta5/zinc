# frozen_string_literal: true

require_relative "lib/zinc_api/version"

Gem::Specification.new do |spec|
  spec.name = "zinc"
  spec.version = ZincApi::VERSION
  spec.authors = ["Abhishek"]
  spec.email = ["zenofabhishek@gmail.com"]

  spec.summary = "Ruby bindings for the Zinc API"
  spec.description = "Zinc is the easiest way to programmatically order from Amazon, Walmart, AliExpress, and more "
  spec.homepage = "https://docs.zincapi.com/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/abhishekgupta5/zinc"
  spec.metadata["changelog_uri"] = "https://github.com/abhishekgupta5/zinc/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.18"
  spec.add_development_dependency "rspec", "~> 3.0"
end
