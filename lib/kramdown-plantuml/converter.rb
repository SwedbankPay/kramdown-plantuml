require 'which'
require 'open3'
require_relative 'version'

module Kramdown::PlantUml
  class Converter
    def initialize
      dir = File.dirname __dir__
      bin = File.join dir, "../bin"
      bin = File.expand_path bin
      @plant_uml_jar_file = File.join bin, "plantuml.1.2020.5.jar"

      if not File.exists? @plant_uml_jar_file
        raise IOError.new("'#{@plant_uml_jar_file}' does not exist")
      end

      unless Which::which("java")
        raise IOError.new("Java can not be found")
      end
    end

    def convert_plantuml_to_svg(content)
      cmd = "java -jar #{@plant_uml_jar_file} -tsvg -pipe"

      stdout, stderr, status = Open3.capture3(cmd, :stdin_data => content)

      unless stderr.empty?
        raise stderr
      end

      remove_from = "@endum"
      remove_to = "--></g>"

      start_index = stdout.index(remove_from) + remove_from.length
      end_index = stdout.index(, remove_to)

      stdout.slice! start_index, end_index

      puts stdout

      return stdout
    end
  end
end
