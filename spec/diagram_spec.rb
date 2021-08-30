# frozen_string_literal: false

require 'kramdown-plantuml/diagram'

Diagram = ::Kramdown::PlantUml::Diagram

describe Diagram do
  plantuml_content = File.read(File.join(__dir__, 'examples', 'diagram.plantuml'))

  describe '#convert_to_svg' do
    context 'gracefully fails' do
      subject { Diagram.new(plantuml).convert_to_svg }

      context 'with nil plantuml' do
        let(:plantuml) { nil }
        it { is_expected.to be_nil }
      end

      context 'with empty plantuml' do
        let(:plantuml) { '' }
        it { is_expected.to be_empty }
      end
    end

    context 'successfully converts' do
      before(:all) { @converted_svg = Diagram.new(plantuml_content).convert_to_svg }
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
    subject { Diagram.new(plantuml, options) }
    let(:options) { {} }

    context 'with invalid PlantUML' do
      let(:plantuml) { 'INVALID!' }

      it do
        expect do
          subject.convert_to_svg.to_s
        end.to raise_error(Kramdown::PlantUml::PlantUmlError, /INVALID!/)
      end
    end

    context 'with non-existing theme' do
      let(:plantuml) { "@startuml\n@enduml" }
      let(:options) { { theme: { name: 'xyz', directory: 'assets' } } }

      it do
        expect do
          subject.convert_to_svg.to_s
        end.to raise_error(Kramdown::PlantUml::PlantUmlError, /theme 'xyz' can't be found in the directory 'assets'/)
      end
    end

    context 'if plantuml.jar is not present', :no_plantuml do
      let(:plantuml) { plantuml_content }

      it do
        expect do
          subject.convert_to_svg.to_s
        end.to raise_error(IOError, /No 'plantuml.jar' file could be found/)
      end
    end

    context 'if Java is not installed', :no_java do
      let(:plantuml) { plantuml_content }

      it do
        expect do
          subject.convert_to_svg.to_s
        end.to raise_error(IOError, 'Java can not be found')
      end
    end
  end
end
