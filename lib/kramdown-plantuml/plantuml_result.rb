# frozen_string_literal: true

require_relative 'logger'
require_relative 'plantuml_error'

module Kramdown
  module PlantUml
    # Executes the PlantUML Java application.
    class PlantUmlResult
      attr_reader :stdout, :stderr, :exitcode

      def initialize(stdout, stderr, status)
        @stdout = stdout
        @stderr = stderr
        @exitcode = status.exitstatus
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

      def validate(plantuml)
        raise PlantUmlError.new(plantuml, @stderr, @exitcode) if PlantUmlError.should_raise?(@exitcode, @stderr)

        return if @stderr.nil? || @stderr.empty?

        @logger.debug 'kramdown-plantuml: PlantUML log:'
        @logger.debug_with_prefix 'kramdown-plantuml: ', @stderr
      end
    end
  end
end
