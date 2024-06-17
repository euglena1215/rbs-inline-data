# frozen_string_literal: true

require_relative "lib/rbs_inline_data/version"

Gem::Specification.new do |spec|
  spec.name = "rbs_inline_data"
  spec.version = RbsInlineData::VERSION
  spec.authors = ["Teppei Shintani"]
  spec.email = ["teppest1215@gmail.com"]

  spec.summary = "Support auto generation of RBS by `Data.define` in rbs-inline syntax"
  spec.description = "Support auto generation of RBS by `Data.define` in rbs-inline syntax"
  spec.homepage = "https://github.com/euglena1215/rbs_inline_data"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/euglena1215/rbs_inline_data"
  spec.metadata["changelog_uri"] = "https://github.com/euglena1215/rbs_inline_data/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "prism"
  spec.add_dependency "rbs"
  spec.metadata["rubygems_mfa_required"] = "true"
end
