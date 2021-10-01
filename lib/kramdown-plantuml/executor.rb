# frozen_string_literal: true

require 'open3'
require_relative '../which'
require_relative 'logger'
require_relative 'plantuml_result'

module Kramdown
  module PlantUml
    # Executes the PlantUML Java application.
    class Executor
      def initialize
        @logger = Logger.init
        @plantuml_jar_file = find_plantuml_jar_file

        raise IOError, 'Java can not be found' unless Which.which('java')
        raise IOError, "No 'plantuml.jar' file could be found" if @plantuml_jar_file.nil?
        raise IOError, "'#{@plantuml_jar_file}' does not exist" unless File.exist? @plantuml_jar_file
      end

      def execute(diagram)
        raise ArgumentError, 'diagram cannot be nil' if diagram.nil?
        raise ArgumentError, "diagram must be a #{Diagram}" unless diagram.is_a?(Diagram)

        cmd = "java -Djava.awt.headless=true -jar #{@plantuml_jar_file} -tsvg -failfast -pipe #{debug_args}"

        @logger.debug "Executing '#{cmd}'."

        stdout, stderr, status = Open3.capture3 cmd, stdin_data: diagram.plantuml

        @logger.debug "PlantUML exit code '#{status.exitstatus}'."

        PlantUmlResult.new(diagram, stdout, stderr, status.exitstatus)
      end

      private

      def find_plantuml_jar_file
        dir = File.dirname __dir__
        jar_glob = File.join dir, '../bin/**/plantuml*.jar'
        first_jar = Dir[jar_glob].first
        File.expand_path first_jar unless first_jar.nil?
      end

      def debug_args
        return ' -verbose' if @logger.debug?

        ' -nometadata'
      end
    end
  end
end
