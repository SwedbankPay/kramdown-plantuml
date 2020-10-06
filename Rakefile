require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation --tag ~no_plantuml --tag ~no_java'
end

namespace :codecov do
  desc 'Uploads the latest SimpleCov result set to codecov.io'
  task :upload do
    require 'simplecov'
    require 'codecov'

    formatter = SimpleCov::Formatter::Codecov.new
    formatter.format(SimpleCov::ResultMerger.merged_result)
  end
end

task default: :spec
