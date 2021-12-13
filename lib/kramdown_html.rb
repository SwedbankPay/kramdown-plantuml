# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'
require_relative 'kramdown-plantuml/log_wrapper'
require_relative 'kramdown-plantuml/plantuml_error'
require_relative 'kramdown-plantuml/options'
require_relative 'kramdown-plantuml/plantuml_diagram'

module Kramdown
  module Converter
    # Plugs into Kramdown::Converter::Html to provide conversion of PlantUML markup
    # into beautiful SVG.
    class Html
      alias super_convert_codeblock convert_codeblock

      def convert_codeblock(element, indent)
        return super_convert_codeblock(element, indent) unless plantuml? element

        convert_plantuml(element.value)
      end

      private

      def plantuml?(element)
        element.attr['class'] == 'language-plantuml'
      end

      def convert_plantuml(plantuml)
        puml_opts = ::Kramdown::PlantUml::Options.new(@options)
        diagram = ::Kramdown::PlantUml::PlantUmlDiagram.new(plantuml, puml_opts)
        diagram.svg.to_s
      rescue StandardError => e
        raise e if puml_opts.nil? || puml_opts.raise_errors?

        logger = ::Kramdown::PlantUml::LogWrapper.init
        logger.error "Error while converting diagram: #{e.inspect}"
      end
    end
  end
end
