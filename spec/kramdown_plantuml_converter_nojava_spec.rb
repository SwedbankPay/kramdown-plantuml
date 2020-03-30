require "spec_helper"
require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter, :exclusively => :no_java do
    context "fails properly" do
        it "if Java is not installed" do
            expect {
                converter = SwedbankPayJekyllPlantuml::Converter.new
            }.to raise_error(IOError, "Java not found")
        end
    end
end
