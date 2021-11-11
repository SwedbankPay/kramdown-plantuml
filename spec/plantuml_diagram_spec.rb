# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/plantuml_diagram'

PlantUmlDiagram ||= ::Kramdown::PlantUml::PlantUmlDiagram

describe PlantUmlDiagram do
  plantuml_content = File.read(File.join(__dir__, 'examples', 'network-diagram.puml'))

  describe '#svg' do
    context 'gracefully fails' do
      subject { PlantUmlDiagram.new(plantuml, Options.new).svg.to_s }

      context 'with nil plantuml' do
        let(:plantuml) { nil }
        it { is_expected.to be_empty }
      end

      context 'with empty plantuml' do
        let(:plantuml) { '' }
        it { is_expected.to be_empty }
      end
    end

    context 'successfully converts' do
      before(:all) { @converted_svg = PlantUmlDiagram.new(plantuml_content, Options.new).svg.to_s }
      subject { @converted_svg }

      it {
        is_expected.not_to include('No @startuml/@enduml found')
      }

      it {
        is_expected.to include('<ellipse')
      }

      it {
        is_expected.to include('<polygon')
      }

      it {
        is_expected.to include('<path')
      }

      it {
        is_expected.to include('<div')
      }

      it {
        is_expected.to include('</div>')
      }

      it {
        is_expected.not_to include('<?xml version=')
      }

      it {
        is_expected.to include('class="plantuml"')
      }
    end
  end

  context 'fails properly' do
    subject { PlantUmlDiagram.new(plantuml, options) }
    let(:hash) { nil }
    let(:options) { Options.new(hash) }

    context 'with invalid PlantUML' do
      let(:plantuml) { 'INVALID!' }

      its(:svg) do
        will raise_error(Kramdown::PlantUml::PlantUmlError, /INVALID!/)
      end

      context ('with raise_errors: false') do
        let(:hash) {  { plantuml: { raise_errors: false } } }
        its(:svg) { will_not raise_error }
      end
    end

    context 'with non-existing theme' do
      let(:plantuml) { "@startuml\n@enduml" }
      let(:hash) { { plantuml: { theme: { name: 'xyz', directory: 'assets' } } } }

      its(:svg) do
        will raise_error(Kramdown::PlantUml::PlantUmlError, /theme 'xyz' can't be found in the directory 'assets'/)
      end

      context ('with raise_errors: false') do
        let(:hash) {  { plantuml: { raise_errors: false } } }
        its(:svg) { will_not raise_error }
      end
    end
  end
end
