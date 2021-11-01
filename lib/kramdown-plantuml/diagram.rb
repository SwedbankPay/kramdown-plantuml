# frozen_string_literal: true

require_relative 'version'
require_relative 'theme'
require_relative 'options'
require_relative 'plantuml_error'
require_relative 'log_wrapper'
require_relative 'executor'

module Kramdown
  module PlantUml
    # Represents a PlantUML diagram that can be converted to SVG.
    class Diagram
      attr_reader :theme, :plantuml, :result

      def initialize(plantuml, options)
        raise ArgumentError, 'options cannot be nil' if options.nil?
        raise ArgumentError, "options must be a '#{Options}'." unless options.is_a?(Options)

        @plantuml = plantuml
        @options = options
        @theme = Theme.new(options)
        @logger = LogWrapper.init
        @executor = Executor.new
        @logger.warn 'PlantUML diagram is empty' if @plantuml.nil? || @plantuml.empty?
      end

      def convert_to_svg
        return @svg unless @svg.nil?
        return @plantuml if @plantuml.nil? || @plantuml.empty?

        @plantuml = @theme.apply(@plantuml)
        log(plantuml)
        @result = @executor.execute(self)
        @result.validate
        @svg = wrap(@result.without_xml_prologue)
      rescue StandardError => e
        raise e if @options.raise_errors?

        @logger.error e.to_s
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
        @logger.debug 'PlantUML converting diagram:'
        @logger.debug_multiline plantuml
      end
    end
  end
end
