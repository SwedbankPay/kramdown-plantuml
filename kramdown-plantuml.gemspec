require_relative 'lib/which'
require_relative 'lib/swedbank-pay-jekyll-plantuml/version'

Gem::Specification.new do |spec|
  spec.name          = "swedbank-pay-jekyll-plantuml"
  spec.version       = SwedbankPayJekyllPlantuml::VERSION
  spec.authors       = ["Asbjørn Ulsberg"]
  spec.email         = ["asbjorn@ulsberg.no"]

  spec.summary       = "Short summary"
  spec.homepage      = "https://github.com/SwedbankPay/swedbank-pay-jekyll-plantuml"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SwedbankPay/swedbank-pay-jekyll-plantuml"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    if Which::which('git')
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    else
      puts "Git not found, no files added to #{spec.name}."
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.2"
end
