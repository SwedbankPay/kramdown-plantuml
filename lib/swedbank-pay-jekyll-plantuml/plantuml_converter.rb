require 'which'
require 'open3'

module SwedbankPayJekyllPlantuml
  class Converter
    def initialize
      @initialized = false
    end

    def lazy_initialize
      if @initialized
        return
      end

      dir = File.dirname __dir__
      bin = File.join dir, "../bin"
      bin = File.expand_path bin
      @plant_uml_jar_file = File.join bin, "plantuml.1.2020.5.jar"
      puts @plant_uml_jar_file

      if not File.exists? @plant_uml_jar_file
        raise IOError.new("'#{@plant_uml_jar_file}' does not exist")
      end

      unless Which::which("java")
        raise IOError.new("Java can not be found")
      else
        puts 'Java found on PATH'
      end

      @initialized = true
    end

    def convert_plantuml_to_svg(content)
      lazy_initialize()

      cmd = "java -jar #{@plant_uml_jar_file} -tsvg -pipe"

      stdout, stderr, status = Open3.capture3(cmd, :stdin_data => content)

      unless stderr.empty?
        raise stderr
      end

      return stdout
    end
  end
end
