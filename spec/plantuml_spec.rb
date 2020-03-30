require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter do
    converter = SwedbankPayJekyllPlantuml::Converter.new
    cwd = File.dirname(__FILE__)
    plantuml_file = File.join(cwd, 'diagram.plantuml')
    plantuml_content = File.read(plantuml_file)

    context "generates a diagram" do
        converted_svg = converter.convert_plantuml_to_svg(plantuml_content).to_s

        puts converted_svg

        it "that is not erroneous" do
            expect(converted_svg).not_to include("No @startuml/@enduml found")
        end

        it "that contains an ellipse" do
            expect(converted_svg).to include("<ellipse")
        end

        it "that contains a polygon" do
            expect(converted_svg).to include("<polygon")
        end

        it "that contains a path" do
            expect(converted_svg).to include("<path")
        end
    end
end
