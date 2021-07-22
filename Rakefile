# frozen_string_literal: true

require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation --tag ~no_plantuml --tag ~no_java'
end

namespace :maven do
  task :install do
    require 'fileutils'

    system 'mvn install'
    bin_dir = File.join __dir__, 'bin'
    target_file = File.join bin_dir, 'plantuml.jar'
    repo_dir = File.expand_path '~/.m2/repository'
    jar_glob = File.join repo_dir, '/**/plantuml*.jar'
    first_jar = Dir[jar_glob].first
    jar_file = File.expand_path first_jar

    FileUtils.mkdir_p bin_dir
    FileUtils.move(jar_file, target_file)
  end
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
