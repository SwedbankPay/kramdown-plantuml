require "spec_helper"
require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter do
    cwd = File.dirname(__FILE__)
    plantuml_file = File.join(cwd, 'diagram.plantuml')
    plantuml_content = File.read(plantuml_file)
    converter = SwedbankPayJekyllPlantuml::Converter.new

    context "generates a diagram", :java do
        let(:converted_svg) {
            converter.convert_plantuml_to_svg(plantuml_content).to_s
        }
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

    context "fails properly", :no_plantuml do
        it "if plantuml.jar is not present" do
            expect {
                converter.convert_plantuml_to_svg(plantuml_content).to_s
            }.to raise_error(IOError, /plantuml.1.2020.5.jar' does not exist/)
        end
    end

    context "fails properly", :no_java do
        it "if Java is not installed" do
            expect {
                converter.convert_plantuml_to_svg(plantuml_content).to_s
            }.to raise_error(IOError, "Java can not be found")
        end
    end
end
