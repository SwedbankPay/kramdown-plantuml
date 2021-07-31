# frozen_string_literal: true

require 'spec_helper'
require 'kramdown-plantuml/converter'

describe Kramdown::PlantUml::Converter do
  plantuml_content = File.read(File.join(__dir__, 'examples', 'diagram.plantuml'))

  context 'convert_plantuml_to_svg' do
    before(:all) do
      converter = Kramdown::PlantUml::Converter.new
      @converted_svg = converter.convert_plantuml_to_svg(plantuml_content)
    end
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

  context 'fails properly' do
    subject { Kramdown::PlantUml::Converter.new }

    it 'with invalid PlantUML' do
      expect do
        subject.convert_plantuml_to_svg('INVALID!').to_s
      end.to raise_error(Kramdown::PlantUml::PlantUmlError, /INVALID!/)
    end

    it 'if plantuml.jar is not present', :no_plantuml do
      expect do
        subject.convert_plantuml_to_svg(plantuml_content).to_s
      end.to raise_error(IOError, /No 'plantuml.jar' file could be found/)
    end

    it 'if Java is not installed', :no_java do
      expect do
        subject.convert_plantuml_to_svg(plantuml_content).to_s
      end.to raise_error(IOError, 'Java can not be found')
    end
  end
end
