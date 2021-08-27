# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'
require_relative 'kramdown-plantuml/logger'
require_relative 'kramdown-plantuml/plantuml_error'
require_relative 'kramdown-plantuml/diagram'

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
        diagram = ::Kramdown::PlantUml::Diagram.new(plantuml, plantuml_options)
        diagram.convert_to_svg
      end
    end
  end
end
