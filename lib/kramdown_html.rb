# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'
require_relative 'kramdown-plantuml/converter'
require_relative 'kramdown-plantuml/logger'
require_relative 'kramdown-plantuml/plantuml_error'

PlantUmlConverter = Kramdown::PlantUml::Converter

module Kramdown
  module Converter
    # Plugs into Kramdown::Converter::Html to provide conversion of PlantUML markup
    # into beautiful SVG.
    class Html
      alias super_convert_codeblock convert_codeblock

      def convert_codeblock(element, indent)
        return super_convert_codeblock(element, indent) if element.attr['class'] != 'language-plantuml'

        plantuml = element.value
        plantuml_options = @options.key?(:plantuml) ? @options[:plantuml] : {}
        converter = PlantUmlConverter.new(plantuml_options || {})
        begin
          converter.convert_plantuml_to_svg(plantuml)
        rescue PlantUmlError
          Logger.init.error("Conversion of the following PlantUML failed: #{plantuml}")
        end
      end
    end
  end
end
