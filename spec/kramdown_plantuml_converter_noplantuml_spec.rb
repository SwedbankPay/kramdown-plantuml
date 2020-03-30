require "spec_helper"
require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter, :exclusively => :no_plantuml do
    context "fails properly" do
        it "if plantuml.jar is not present" do
            expect {
                converter = SwedbankPayJekyllPlantuml::Converter.new
            }.to raise_error(IOError, "'plantuml.1.2020.5.jar' not found")
        end
    end
end
