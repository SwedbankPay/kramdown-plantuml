# frozen_string_literal: true

require 'kramdown'
require 'kramdown-plantuml/converter'

class Kramdown::Converter::Html
  alias super_convert_codeblock convert_codeblock

  def convert_codeblock(element, indent)
    return super_convert_codeblock(element, indent) if element.attr['class'] != 'language-plantuml'

    converter = Kramdown::PlantUml::Converter.new
    converter.convert_plantuml_to_svg(element.value)
  end
end
