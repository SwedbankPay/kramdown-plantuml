require 'kramdown'
require "kramdown-plantuml/converter"

class Kramdown::Converter::Html
    alias_method :super_convert_codeblock, :convert_codeblock

    def convert_codeblock(element, indent)
        if element.attr["class"] != "language-plantuml"
            return super_convert_codeblock(element, indent)
        end

        converter = Kramdown::PlantUml::Converter.new
        return converter.convert_plantuml_to_svg(element.value)
    end
end
