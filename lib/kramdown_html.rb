# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'
require_relative 'kramdown-plantuml/converter'
require_relative 'kramdown-plantuml/logger'
require_relative 'kramdown-plantuml/plantuml_error'

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
        converter = ::Kramdown::PlantUml::Converter.new(plantuml_options || {})

        converter.convert_plantuml_to_svg(plantuml)
      end
    end
  end
end
