require "spec_helper"
require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter, :only_if => :no_plantuml do
    converter = SwedbankPayJekyllPlantuml::Converter.new

    context "fails properly" do
        it "if plantuml.jar is not present" do
            expect {
                converter.convert_plantuml_to_svg('plantuml')
            }.to raise_error(IOError, "'plantuml.1.2020.5.jar' not found")
        end
    end
end
