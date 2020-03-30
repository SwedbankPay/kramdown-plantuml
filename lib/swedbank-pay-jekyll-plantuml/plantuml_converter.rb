require 'open3'

module SwedbankPayJekyllPlantuml
  class Converter
    def initialize
      dir = File.dirname __dir__
      bin = File.join dir, "../bin"
      bin = File.expand_path bin
      @plant_uml_jar_file = File.join bin, "plantuml.1.2020.5.jar"
      puts @plant_uml_jar_file

      if not File.exists? @plant_uml_jar_file
        raise Error.new("'#{@plant_uml_jar_file}' does not exist")
      end

      puts @plant_uml_jar_file
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      nil
    end

    def convert_plantuml_to_svg(content)

      unless which("java")
        raise "Java can not be found"
      end

      cmd = "java -jar #{@plant_uml_jar_file} -tsvg -pipe"

      stdout, stderr, status = Open3.capture3(cmd, :stdin_data => content)

      unless stderr.empty?
        raise stderr
      end

      return stdout
    end
  end
end
