# frozen_string_literal: true

require_relative 'version'
require_relative 'theme'
require_relative 'plantuml_error'
require_relative 'logger'
require_relative 'executor'

module Kramdown
  module PlantUml
    # Represents a PlantUML diagram that can be converted to SVG.
    class Diagram
      attr_reader :theme, :plantuml, :result

      def initialize(plantuml, options = {})
        @plantuml = plantuml
        @theme = Theme.new(options || {})
        @logger = Logger.init
        @executor = Executor.new
        @logger.warn ' kramdown-plantuml: PlantUML diagram is empty' if @plantuml.nil? || @plantuml.empty?
      end

      def convert_to_svg
        return @svg unless @svg.nil?
        return @plantuml if @plantuml.nil? || @plantuml.empty?

        @plantuml = @theme.apply(@plantuml)
        @plantuml = plantuml.strip
        log(plantuml)
        @result = @executor.execute(self)
        @result.validate
        @svg = wrap(@result.without_xml_prologue)
        @svg
      end

      private

      def wrap(svg)
        theme_class = @theme.name ? "theme-#{@theme.name}" : ''
        class_name = "plantuml #{theme_class}".strip

        wrapper_element_start = "<div class=\"#{class_name}\">"
        wrapper_element_end = '</div>'

        "#{wrapper_element_start}#{svg}#{wrapper_element_end}"
      end

      def log(plantuml)
        @logger.debug ' kramdown-plantuml: PlantUML converting diagram:'
        @logger.debug_with_prefix ' kramdown-plantuml: ', plantuml
      end
    end
  end
end
