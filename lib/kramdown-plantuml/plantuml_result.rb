# frozen_string_literal: true

require_relative 'logger'
require_relative 'plantuml_error'
require_relative 'diagram'

module Kramdown
  module PlantUml
    # Executes the PlantUML Java application.
    class PlantUmlResult
      attr_reader :diagram, :stdout, :stderr, :exitcode

      def initialize(diagram, stdout, stderr, exitcode)
        raise ArgumentError, 'diagram cannot be nil' if diagram.nil?
        raise ArgumentError, "diagram must be a #{Diagram}" unless diagram.is_a?(Diagram)
        raise ArgumentError, 'exitcode cannot be nil' if exitcode.nil?
        raise ArgumentError, "exitcode must be a #{Integer}" unless exitcode.is_a?(Integer)

        @diagram = diagram
        @stdout = stdout
        @stderr = stderr
        @exitcode = exitcode
        @logger = Logger.init
      end

      def without_xml_prologue
        return @stdout if @stdout.nil? || @stdout.empty?

        xml_prologue_start = '<?xml'
        xml_prologue_end = '?>'

        start_index = @stdout.index(xml_prologue_start)

        return @stdout if start_index.nil?

        end_index = @stdout.index(xml_prologue_end, xml_prologue_start.length)

        return @stdout if end_index.nil?

        end_index += xml_prologue_end.length

        @stdout.slice! start_index, end_index

        @stdout
      end

      def valid?
        return true if @exitcode.zero? || @stderr.nil? || @stderr.empty?

        # If stderr is not empty, but contains the string 'CoreText note:',
        # the error is caused by a bug in Java, and should be ignored.
        # Circumvents https://bugs.openjdk.java.net/browse/JDK-8244621
        @stderr.include?('CoreText note:')
      end

      def validate
        raise PlantUmlError, self unless valid?

        return if @stderr.nil? || @stderr.empty?

        @logger.debug 'PlantUML log:'
        @logger.debug_multiline @stderr
      end
    end
  end
end
