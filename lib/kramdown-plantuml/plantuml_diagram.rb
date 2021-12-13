# frozen_string_literal: true

require_relative 'executor'
require_relative 'log_wrapper'
require_relative 'options'
require_relative 'plantuml_error'
require_relative 'svg_diagram'
require_relative 'theme'
require_relative 'version'

module Kramdown
  module PlantUml
    # Represents a PlantUML diagram that can be converted to SVG.
    class PlantUmlDiagram
      attr_reader :theme, :plantuml, :result, :options

      def initialize(plantuml, options)
        raise ArgumentError, 'options cannot be nil' if options.nil?
        raise ArgumentError, "options must be a '#{Options}'." unless options.is_a?(Options)

        @plantuml = plantuml.strip unless plantuml.nil?
        @options = options
        @theme = Theme.new(options)
        @logger = LogWrapper.init
        @executor = Executor.new
        @logger.warn 'PlantUML diagram is empty' if @plantuml.nil? || @plantuml.empty?
      end

      def svg
        return @svg_diagram unless @svg_diagram.nil?

        @plantuml = @theme.apply(@plantuml)
        log(@plantuml)
        @result = @executor.execute(self)
        @svg_diagram = SvgDiagram.new(@result)
      rescue StandardError => e
        raise e if @options.raise_errors?

        @logger.error e.to_s
      end

      private

      def log(plantuml)
        @logger.debug 'PlantUML converting diagram:'
        @logger.debug_multiline plantuml
      end
    end
  end
end
