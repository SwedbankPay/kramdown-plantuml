require "spec_helper"
require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter do
    cwd = File.dirname(__FILE__)
    plantuml_file = File.join(cwd, 'diagram.plantuml')
    plantuml_content = File.read(plantuml_file)
    converter = SwedbankPayJekyllPlantuml::Converter.new

    puts "ENV:JAVA: #{ENV['JAVA']}"
    puts "ENV:NO_JAVA: #{ENV['NO_JAVA']}"
    puts "ENV:NO_PLANTUML: #{ENV['NO_PLANTUML']}"

    context "generates a diagram", :requires => :java do
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

    context "fails properly", :requires => :no_plantuml do
        it "if plantuml.jar is not present" do
            expect {
                converter.convert_plantuml_to_svg(plantuml_content).to_s
            }.to raise_error(IOError, "'plantuml.1.2020.5.jar' not found")
        end
    end

    context "fails properly", :requires => :no_java do
        it "if Java is not installed" do
            expect {
                converter.convert_plantuml_to_svg(plantuml_content).to_s
            }.to raise_error(IOError, "Java not found")
        end
    end
end
