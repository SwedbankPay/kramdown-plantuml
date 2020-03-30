require "spec_helper"
require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter do
    subject (:converter) {
        SwedbankPayJekyllPlantuml::Converter.new
    }

    let (:plantuml_content) {
        cwd = File.dirname(__FILE__)
        plantuml_file = File.join(cwd, 'diagram.plantuml')
        File.read(plantuml_file)
    }

    context "convert_plantuml_to_svg", :java do
        subject {
            # TODO: Figure out how to do convert_plantuml_to_svg just once for the entire context.
            converter.convert_plantuml_to_svg(plantuml_content).to_s
        }

        it "is not erroneous" do
            is_expected.not_to include("No @startuml/@enduml found")
        end

        it "contains an ellipse" do
            is_expected.to include("<ellipse")
        end

        it "contains a polygon" do
            is_expected.to include("<polygon")
        end

        it "contains a path" do
            is_expected.to include("<path")
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
