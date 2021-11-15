# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/options'
require 'kramdown-plantuml/jekyll_provider'

Options ||= Kramdown::PlantUml::Options
JekyllProvider = ::Kramdown::PlantUml::JekyllProvider

describe JekyllProvider do
  let (:plantuml_file_contents) { File.read(File.join(__dir__, 'examples', 'network-diagram.puml')) }
  let (:plantuml) { nil }
  let (:options) { Options.new }
  subject { JekyllProvider }

  context 'without jekyll' do
    its (:jekyll) { is_expected.to be_nil }
    its (:install) { is_expected.to be false }
    its (:installed?) { is_expected.to be false }

    describe '#needle' do
      subject { JekyllProvider.needle(plantuml, options) }

      context 'when plantuml is nil' do
        it { is_expected.to match(/<!--#kramdown-plantuml\.start#-->.*<!--#kramdown-plantuml\.end#-->/m) }
      end

      context 'when plantuml is valid' do
        let (:plantuml) { plantuml_file_contents }
        it { is_expected.to match(/<!--#kramdown-plantuml\.start#-->.*@startuml.*@enduml.*<!--#kramdown-plantuml\.end#-->/m) }
      end

      context 'when options has theme' do
        let (:options) { Options.new({ plantuml: { theme: { name: 'spacelab'} } }) }
        it { is_expected.to match(/<!--#kramdown-plantuml\.start#-->.*spacelab.*<!--#kramdown-plantuml\.end#-->/m) }
      end
    end
  end

  context 'with jekyll', :jekyll do
    its (:jekyll) { is_expected.not_to be_nil }
    its (:install) { is_expected.to be true }
    its (:installed?) { is_expected.to be true }

    describe 'jekyll build' do
      jekyll_source = File.join(__dir__, 'examples')
      jekyll_destination = File.join(jekyll_source, '_site')

      before(:all) do
        Jekyll::Commands::Build.process({
          'config' => File.join(jekyll_source, '_config.yml'),
          'incremental' => false,
          'source' => jekyll_source,
          'verbose' => ENV.fetch('DEBUG', false),
          'destination' => jekyll_destination
        })
      end

      subject { File.read(File.join(jekyll_destination, 'index.html')) }

      context 'when plantuml contains HTML entities', :jekyll do
        it do
          is_expected.to have_tag('div', with: { class: 'plantuml' }) do
            with_tag('svg')
          end
        end

        it { is_expected.to have_tag('h1', text: 'This is a fixture') }
      end
    end
  end
end
