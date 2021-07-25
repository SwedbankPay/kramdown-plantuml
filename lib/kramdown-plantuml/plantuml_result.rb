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

      def validate(plantuml)
        raise PlantUmlError.new(plantuml, @stderr, @exitcode) if PlantUmlError.should_raise?(@exitcode, @stderr)

        return if @stderr.nil? || @stderr.empty?

        @logger.debug("PlantUML log:\n#{@stderr}")
      end
    end
  end
end
