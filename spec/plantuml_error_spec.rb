# frozen_string_literal: true

require 'spec_helper'
require 'rspec/its'
require 'kramdown-plantuml/plantuml_error'

describe Kramdown::PlantUml::PlantUmlError do
  describe '#should_raise?' do
    subject {
      Kramdown::PlantUml::PlantUmlError.should_raise?(stderr)
    }

    context 'when stderr is nil' do
      let(:stderr) { nil }
      it { is_expected.to be false }
    end

    context 'when stderr is empty' do
      let(:stderr) { '' }
      it { is_expected.to be false }
    end

    context 'when stderr is not empty' do
      let(:stderr) { 'some stderr' }
      it { is_expected.to be true }
    end

    context 'when stderr is CoreText bug' do
      let(:stderr) { 'CoreText note:' }
      it { is_expected.to be false }
    end
  end

  describe '#new' do
    subject {
      Kramdown::PlantUml::PlantUmlError.new(plantuml, stderr)
    }

    context 'message is expected' do
      let (:plantuml) { 'some plantuml' }
      let (:stderr) { 'some stderr' }

      it { is_expected.to be_a Kramdown::PlantUml::PlantUmlError }
      its(:message) {
        is_expected.to match(/some plantuml/)
        is_expected.to match(/some stderr/)
      }
    end
  end
end
