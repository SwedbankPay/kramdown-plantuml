# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/themer'

describe Kramdown::PlantUml::Themer do
  describe '#apply_theme' do
    let(:options) { nil }
    subject { Kramdown::PlantUml::Themer.new(options).apply_theme(plantuml) }

    context 'with nil plantuml' do
      let(:plantuml) { nil }
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
      let(:options) { { theme: { name: 'spacelab' } } }
      let(:plantuml) { "@startuml\nactor A\nend" }
      it { is_expected.to eq("@startuml\n!theme spacelab\nactor A\nend") }
    end

    context 'with custom theme' do
      let(:options) { { theme: { name: 'custom', directory: 'path/to/themes' } } }
      let(:plantuml) { "@startuml\nactor A\nend" }
      it { is_expected.to eq("@startuml\n!theme custom from path/to/themes\nactor A\nend") }
    end
  end
end
