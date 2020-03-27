# require_relative '../lib/swedbank/pay/jekyll/plantuml_converter'
require "swedbank/pay/jekyll/plantuml/plantuml_converter"

describe Swedbank::Pay::Jekyll::Plantuml::Converter do
    it "creates plantuml" do
        converter = Swedbank::Pay::Jekyll::Plantuml::Converter.new
        str = "@startuml\
        actor client\
        node app\
        database db\
        db -> app\
        app -> client\
        @enduml"
        converted_svg = converter.convert_plantuml_to_svg(str).to_s
        puts converted_svg
        expected_svg = '<?xml version="1.0" encoding="UTF-8" standalone="no"?><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" contentScriptType="application/ecmascript" contentStyleType="text/css" height="22px" preserveAspectRatio="none" style="width:227px;height:22px;background:#000000;" version="1.1" viewBox="0 0 227 22" width="227px" zoomAndPan="magnify"><defs/><g><text fill="#33FF02" font-family="sans-serif" font-size="14" font-weight="bold" lengthAdjust="spacingAndGlyphs" textLength="220" x="5" y="19">No @startuml/@enduml found</text></g></svg>'
        expect(converted_svg).to eq(expected_svg)
    end
end
