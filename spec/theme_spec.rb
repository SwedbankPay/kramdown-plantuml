# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/options'
require 'kramdown-plantuml/theme'

Theme = Kramdown::PlantUml::Theme
Options = Kramdown::PlantUml::Options

describe Theme do
  describe '#initialize' do
    let(:options) { Options.new }
    subject { Theme.new(options) }

    context 'with symbolic option keys' do
      let(:options) { Options.new({ plantuml: { theme: { name: 'custom', directory: 'path/to/themes' } } }) }
      its(:name) { is_expected.to eq('custom') }
      its(:directory) { is_expected.to eq('path/to/themes') }
    end

    context 'with mixed option keys' do
      let(:options) { Options.new({ plantuml: { theme: { 'name' => 'custom', 'directory' => 'path/to/themes' } } }) }
      its(:name) { is_expected.to eq('custom') }
      its(:directory) { is_expected.to eq('path/to/themes') }
    end

    context 'with string option keys' do
      let(:options) { Options.new({ 'plantuml' => { 'theme' => { 'name' => 'custom', 'directory' => 'path/to/themes' } } }) }
      its(:name) { is_expected.to eq('custom') }
      its(:directory) { is_expected.to eq('path/to/themes') }
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
      let(:plantuml) { "@startuml\nactor A\nend" }
      it { is_expected.to eq("@startuml\nactor A\nend") }
    end

    context 'with built-in theme' do
      let(:options) { Options.new({ plantuml: { theme: { name: 'spacelab' } } }) }
      let(:plantuml) { "@startuml\nactor A\nend" }
      it { is_expected.to eq("@startuml\n!theme spacelab\nactor A\nend") }
    end

    context 'with custom theme' do
      let(:options) { Options.new({ plantuml: { theme: { name: 'custom', directory: 'path/to/themes' } } }) }
      let(:plantuml) { "@startuml\nactor A\nend" }
      it { is_expected.to eq("@startuml\n!theme custom from path/to/themes\nactor A\nend") }
    end
  end
end
