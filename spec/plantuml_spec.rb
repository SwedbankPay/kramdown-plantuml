require 'rspec/matchers'
require 'equivalent-xml'
require "swedbank/pay/jekyll/plantuml/plantuml_converter"

describe Swedbank::Pay::Jekyll::Plantuml::Converter do
    it "creates plantuml" do
        converter = Swedbank::Pay::Jekyll::Plantuml::Converter.new
        cwd = File.dirname(__FILE__)
        plantuml_file = File.join(cwd, 'diagram.plantuml')
        svg_file = File.join(cwd, 'diagram.svg')
        plantuml_content = File.read(plantuml_file)
        expected_svg = File.read(svg_file)

        # puts plantuml_content
        converted_svg = converter.convert_plantuml_to_svg(plantuml_content).to_s
        puts converted_svg

        expect(converted_svg).to be_equivalent_to(expected_svg)
    end
end
