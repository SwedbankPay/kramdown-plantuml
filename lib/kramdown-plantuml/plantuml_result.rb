# frozen_string_literal: true

require_relative 'log_wrapper'
require_relative 'plantuml_error'
require_relative 'svg_diagram'

module Kramdown
  module PlantUml
    # Executes the PlantUML Java application.
    class PlantUmlResult
      attr_reader :plantuml_diagram, :stdout, :stderr, :exitcode

      def initialize(plantuml_diagram, stdout, stderr, exitcode)
        raise ArgumentError, 'diagram cannot be nil' if plantuml_diagram.nil?
        raise ArgumentError, "diagram must be a #{PlantUmlDiagram}" unless plantuml_diagram.is_a?(PlantUmlDiagram)
        raise ArgumentError, 'exitcode cannot be nil' if exitcode.nil?
        raise ArgumentError, "exitcode must be a #{Integer}" unless exitcode.is_a?(Integer)

        @plantuml_diagram = plantuml_diagram
        @stdout = stdout
        @stderr = stderr
        @exitcode = exitcode
        @logger = LogWrapper.init
      end

      def svg_diagram
        @plantuml_diagram.svg
      end

      def valid?
        return true if @exitcode.zero? || @stderr.nil? || @stderr.empty?

        # If stderr is not empty, but contains the string 'CoreText note:',
        # the error is caused by a bug in Java, and should be ignored.
        # Circumvents https://bugs.openjdk.java.net/browse/JDK-8244621
        @stderr.include?('CoreText note:')
      end

      def validate!
        raise PlantUmlError, self unless valid?

        return if @stderr.nil? || @stderr.empty?

        @logger.debug 'PlantUML log:'
        @logger.debug_multiline @stderr
      end
    end
  end
end
