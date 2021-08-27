# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/plantuml_error'

describe Kramdown::PlantUml::PlantUmlError do
  describe '#new' do
    subject {
      diagram = ::Kramdown::PlantUml::Diagram.new(plantuml)
      result = ::Kramdown::PlantUml::PlantUmlResult.new(diagram, '', stderr, exitcode)
      Kramdown::PlantUml::PlantUmlError.new(result)
    }

    context 'message is expected' do
      let (:plantuml) { 'some plantuml' }
      let (:stderr) { 'some stderr' }
      let (:exitcode) { 1 }

      it { is_expected.to be_a Kramdown::PlantUml::PlantUmlError }
      its(:message) {
        is_expected.to match(/some plantuml/)
        is_expected.to match(/some stderr/)
        is_expected.to match(/Exit code: 1/)
      }
    end
  end
end
