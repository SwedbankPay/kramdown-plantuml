require "kramdown_html"

describe Kramdown::Converter::Html do
   it "creates a plantuml" do
    # TODO: Figure out how to instantiate and test Kramdown::Converter::Html
    #    kramdown = Kramdown::Converter::Html.new(nil, nil)
    #    str = "@startuml\
    #    actor client\
    #    node app\
    #    database db\
    #    db -> app\
    #    app -> client\
    #    @enduml"
    #    expect(kramdown.convert(str)).to.include("PlantUML version 1.2020.02(Sun Mar 01 04:22:07 CST 2020)")
   end
end
