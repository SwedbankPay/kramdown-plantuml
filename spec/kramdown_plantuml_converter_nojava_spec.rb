require "spec_helper"
require "swedbank-pay-jekyll-plantuml/plantuml_converter"

describe SwedbankPayJekyllPlantuml::Converter, :exclusively => :nojava do
    converter = SwedbankPayJekyllPlantuml::Converter.new

    context "fails properly" do
        it "if Java is not installed" do
            expect {
                converter.convert_plantuml_to_svg('plantuml')
            }.to raise_error(IOError, "Java not found")
        end
    end
end
