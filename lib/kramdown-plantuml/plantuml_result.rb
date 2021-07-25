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
        raise PlantUmlError.new(plantuml, @stderr) if PlantUmlError.should_raise?(@exitcode, @stderr)

        # If we have both stdout and stderr, the conversion succeeded, but
        # warnings may have been written to stderr which we should pass on.
        return unless !@stdout.nil? && !@stdout.empty? && !@stderr.nil? && !@stderr.empty?

        @logger.warn("PlantUML warning:\n#{@stderr}\nFor diagram:\n#{plantuml}")
      end
    end
  end
end
