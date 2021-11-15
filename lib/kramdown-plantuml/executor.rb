# frozen_string_literal: true

require 'open3'
require_relative 'which'
require_relative 'log_wrapper'
require_relative 'plantuml_result'

module Kramdown
  module PlantUml
    # Executes the PlantUML Java application.
    class Executor
      def initialize
        @logger = LogWrapper.init

        java_location = Which.which('java')

        raise IOError, 'Java can not be found' if java_location.nil?

        @logger.debug "Java found: #{java_location}"
        @plantuml_jar_file = find_plantuml_jar_file

        raise IOError, "'#{@plantuml_jar_file}' does not exist" unless File.exist? @plantuml_jar_file

        @logger.debug "plantuml.jar found: #{@plantuml_jar_file}"
      end

      def execute(diagram)
        raise ArgumentError, 'diagram cannot be nil' if diagram.nil?
        raise ArgumentError, "diagram must be a #{PlantUmlDiagram}" unless diagram.is_a?(PlantUmlDiagram)

        cmd = "java -Djava.awt.headless=true -jar #{@plantuml_jar_file} -tsvg -failfast -pipe #{debug_args}"

        @logger.debug "Executing '#{cmd}'."

        stdout, stderr, status = Open3.capture3 cmd, stdin_data: diagram.plantuml

        @logger.debug "PlantUML exit code '#{status.exitstatus}'."

        PlantUmlResult.new(diagram, stdout, stderr, status.exitstatus)
      end

      private

      def find_plantuml_jar_file
        dir = File.dirname __dir__
        bin_dir = File.expand_path File.join dir, '../bin'
        jar_glob = File.join bin_dir, '/**/plantuml*.jar'
        first_jar = Dir[jar_glob].first

        raise IOError, "No 'plantuml.jar' file could be found within the '#{bin_dir}' directory." if first_jar.nil?

        File.expand_path first_jar
      end

      def debug_args
        return ' -verbose' if @logger.debug?

        ' -nometadata'
      end
    end
  end
end
