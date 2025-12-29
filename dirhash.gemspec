# frozen_string_literal: true

require_relative "lib/dirhash/version"

Gem::Specification.new do |spec|
  spec.name = "dirhash"
  spec.version = Dirhash::VERSION
  spec.authors = ["Andrew Nesbitt"]
  spec.email = ["andrewnez@gmail.com"]

  spec.summary = "Generate Go module zip digests compatible with sum.golang.org"
  spec.description = "Generate digests and manifests of Go module zip contents using the same algorithm as Go's sumdb dirhash"
  spec.homepage = "https://github.com/foragepm/dirhash-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/foragepm/dirhash-rb"
  spec.metadata["changelog_uri"] = "https://github.com/foragepm/dirhash-rb/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rubyzip", "~> 2.3"
  spec.add_dependency "base64"
end
