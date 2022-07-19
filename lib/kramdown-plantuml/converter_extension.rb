# frozen_string_literal: true

module Kramdown
  module PlantUml
    # Plugs into Kramdown::Converter::Html to provide conversion of PlantUML markup
    # into beautiful SVG.
    module ConverterExtension
      def convert_codeblock(element, indent)
        return super(element, indent) unless plantuml? element

        convert_plantuml(element.value)
      end

      private

      def plantuml?(element)
        element.attr['class'] == 'language-plantuml'
      end

      def convert_plantuml(plantuml)
        puml_opts = PlantUml::Options.new(@options)
        diagram = PlantUml::PlantUmlDiagram.new(plantuml, puml_opts)
        diagram.svg.to_s
      rescue StandardError => e
        raise e if puml_opts.nil? || puml_opts.raise_errors?

        logger = PlantUml::LogWrapper.init
        logger.error "Error while converting diagram: #{e.inspect}"
      end
    end
  end
end
