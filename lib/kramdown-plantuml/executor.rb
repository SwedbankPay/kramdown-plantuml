# frozen_string_literal: false

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

      def execute(stdin)
        cmd = "java -Djava.awt.headless=true -jar #{@plantuml_jar_file} -tsvg -failfast -pipe"
        cmd << if @logger.debug?
                 ' -verbose'
               else
                 ' -nometadata'
               end

        @logger.debug "PlantUML executing: #{cmd}"

        stdout, stderr, status = Open3.capture3 cmd, stdin_data: stdin

        @logger.debug "PlantUML exit code: #{status.exitstatus}"

        PlantUmlResult.new(stdout, stderr, status)
      end

      private

      def find_plantuml_jar_file
        dir = File.dirname __dir__
        jar_glob = File.join dir, '../bin/**/plantuml*.jar'
        first_jar = Dir[jar_glob].first
        File.expand_path first_jar unless first_jar.nil?
      end
    end
  end
end
