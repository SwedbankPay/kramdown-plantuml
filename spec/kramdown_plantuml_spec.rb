# frozen_string_literal: true

require 'spec_helper'
require 'kramdown-plantuml/converter'

describe Kramdown::PlantUml::Converter do
  cwd = File.dirname(__FILE__)
  plantuml_file = File.join(cwd, 'diagram.plantuml')
  plantuml_content = File.read(plantuml_file)

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
    subject(:converter) do
      Kramdown::PlantUml::Converter.new
    end

    it 'if plantuml.jar is not present', :no_plantuml do
      expect do
        converter.convert_plantuml_to_svg(plantuml_content).to_s
      end.to raise_error(IOError, /plantuml.1.2020.5.jar' does not exist/)
    end

    it 'if Java is not installed', :no_java do
      expect do
        converter.convert_plantuml_to_svg(plantuml_content).to_s
      end.to raise_error(IOError, 'Java can not be found')
    end
  end
end
