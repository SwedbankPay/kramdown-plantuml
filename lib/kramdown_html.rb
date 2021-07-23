# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'
require_relative 'kramdown-plantuml/converter'

PlantUmlConverter = Kramdown::PlantUml::Converter

module Kramdown
  module Converter
    # Plugs into Kramdown::Converter::Html to provide conversion of PlantUML markup
    # into beautiful SVG.
    class Html
      alias super_convert_codeblock convert_codeblock

      def convert_codeblock(element, indent)
        return super_convert_codeblock(element, indent) if element.attr['class'] != 'language-plantuml'

        plantuml_options = @options.key?(:plantuml) ? @options[:plantuml] : {}
        converter = PlantUmlConverter.new(plantuml_options || {})
        converter.convert_plantuml_to_svg(element.value)
      end
    end
  end
end
