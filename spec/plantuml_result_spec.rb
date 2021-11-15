# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/plantuml_result'

describe Kramdown::PlantUml::PlantUmlResult do
  describe '#valid?' do
    let (:exitcode) { 1 }
    let (:stderr) { nil }

    subject {
      diagram = ::Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", Options.new)
      result = ::Kramdown::PlantUml::PlantUmlResult.new(diagram, '', stderr, exitcode)
      result.valid?
    }

    context 'when stderr is nil' do
      let(:stderr) { nil }
      it { is_expected.to be true }
    end

    context 'when stderr is empty' do
      let(:stderr) { '' }
      it { is_expected.to be true }
    end

    context 'when stderr is not empty' do
      let(:stderr) { 'some stderr' }
      it { is_expected.to be false }
    end

    context 'when stderr is CoreText bug' do
      let(:stderr) { 'CoreText note:' }
      it { is_expected.to be true }
    end

    context 'when exitcode is 0' do
      it { is_expected.to be true }
    end

    context 'when exitcode is 1' do
      let(:stderr) { 'error' }
      it { is_expected.to be false }
    end
  end

  describe '#initialize' do
    subject {
      diagram = ::Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", Options.new)
      ::Kramdown::PlantUml::PlantUmlResult.new(diagram, stdout, stderr, exitcode)
    }

    context 'message is expected' do
      let (:stderr) { 'some stderr' }
      let (:stdout) { 'some stdout' }
      let (:exitcode) { 1337 }

      its(:plantuml_diagram) {
        is_expected.to be_a ::Kramdown::PlantUml::PlantUmlDiagram
      }

      its(:svg_diagram) {
        is_expected.to be_a ::Kramdown::PlantUml::SvgDiagram
      }

      its(:stdout) {
        is_expected.to eq stdout
      }

      its(:stderr) {
        is_expected.to eq stderr
      }

      its(:exitcode) {
        is_expected.to eq exitcode
      }
    end
  end
end
