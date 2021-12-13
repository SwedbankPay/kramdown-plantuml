# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/options'
require 'kramdown-plantuml/theme'

Theme = Kramdown::PlantUml::Theme
Options ||= Kramdown::PlantUml::Options

describe Theme do
  describe '#initialize' do
    let(:options) { Options.new }
    subject { Theme.new(options) }

    context 'with symbolic option keys' do
      let(:options) { Options.new({ plantuml: { theme: { name: 'c2a3b0', directory: 'spec/examples' }, scale: 0.8 } }) }
      its(:name) { is_expected.to eq('c2a3b0') }
      its(:directory) { is_expected.to match(/spec\/examples$/) }
      its(:scale) { is_expected.to eq(0.8) }
    end

    context 'with mixed option keys' do
      let(:options) { Options.new({ plantuml: { theme: { 'name' => 'c2a3b0', 'directory' => 'spec/examples' }, scale: '0.8' } }) }
      its(:name) { is_expected.to eq('c2a3b0') }
      its(:directory) { is_expected.to match(/spec\/examples$/) }
      its(:scale) { is_expected.to eq('0.8') }
    end

    context 'with string option keys' do
      let(:options) { Options.new({ 'plantuml' => { 'theme' => { 'name' => 'c2a3b0', 'directory' => 'spec/examples' }, 'scale' => '0.8' } }) }
      its(:name) { is_expected.to eq('c2a3b0') }
      its(:directory) { is_expected.to match(/spec\/examples$/) }
      its(:scale) { is_expected.to eq('0.8') }
    end
  end

  describe '#apply' do
    let(:options) { Options.new }
    let(:plantuml) { nil }

    subject { Theme.new(options).apply(plantuml) }

    context 'with nil plantuml' do
      it { is_expected.to be_nil }
    end

    context 'with empty plantuml' do
      let(:plantuml) { '' }
      it { is_expected.to be_empty }
    end

    context 'with simple plantuml' do
      let(:plantuml) { "@startuml\nactor A\n@enduml" }
      it { is_expected.to eq("@startuml\nactor A\n@enduml") }
    end

    context 'with built-in theme' do
      let(:options) { Options.new({ plantuml: { theme: { name: 'spacelab' } } }) }
      let(:plantuml) { "@startuml\nactor A\n@enduml" }
      it { is_expected.to eq("@startuml\n!theme spacelab\nactor A\n@enduml") }
    end

    context 'with custom theme' do
      let(:options) { Options.new({ plantuml: { theme: { name: 'c2a3b0', directory: 'spec/examples' } } }) }
      let(:plantuml) { "@startuml\nactor A\n@enduml" }
      it { is_expected.to match(/@startuml\n!theme c2a3b0 from .*spec\/examples\nactor A\n@enduml/) }
    end

    context 'with scale' do
      let(:options) { Options.new({ plantuml: { scale: 0.8 } }) }
      let(:plantuml) { "@startuml\nactor A\n@enduml" }
      it { is_expected.to eq("@startuml\nscale 0.8\nactor A\n@enduml") }
    end
  end
end
