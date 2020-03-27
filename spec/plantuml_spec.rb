require "swedbank/pay/jekyll/plantuml/plantuml_converter"

describe Swedbank::Pay::Jekyll::Plantuml::Converter do
    it "creates plantuml" do
        converter = Swedbank::Pay::Jekyll::Plantuml::Converter.new
        cwd = File.dirname(__FILE__)
        plantuml_file = File.join(cwd, 'diagram.plantuml')
        plantuml_content = File.read(plantuml_file)
        converted_svg = converter.convert_plantuml_to_svg(plantuml_content).to_s

        puts converted_svg

        expect(converted_svg).not_to include("No @startuml/@enduml found")
        expect(converted_svg).to include("<ellipse")
        expect(converted_svg).to include("<polygon")
        expect(converted_svg).to include("<path")
    end
end
