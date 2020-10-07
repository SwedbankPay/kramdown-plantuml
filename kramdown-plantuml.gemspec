# frozen_string_literal: true

require_relative 'lib/which'
require_relative 'lib/kramdown-plantuml/version'

Gem::Specification.new do |spec|
  spec.name          = 'kramdown-plantuml'
  spec.version       = Kramdown::PlantUml::VERSION
  spec.authors       = ['Asbjørn Ulsberg']
  spec.email         = ['asbjorn@ulsberg.no']

  spec.summary       = 'Short summary'
  spec.homepage      = 'https://github.com/SwedbankPay/kramdown-plantuml'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/SwedbankPay/kramdown-plantuml'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    if Which.which('git')
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    else
      puts "Git not found, no files added to #{spec.name}."
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'kramdown', '~> 2.3'
  spec.add_dependency 'open3', '~> 0.1'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rubocop', '~> 0.92'
end
