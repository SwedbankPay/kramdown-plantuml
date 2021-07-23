# frozen_string_literal: true

require 'open3'
require_relative '../which'
require_relative 'version'
require_relative 'themer'

module Kramdown
  module PlantUml
    # Converts PlantUML markup to SVG
    class Converter
      def initialize(options = {})
        @themer = Themer.new(options)

        dir = File.dirname __dir__
        jar_glob = File.join dir, '../bin/**/plantuml*.jar'
        first_jar = Dir[jar_glob].first
        @plant_uml_jar_file = File.expand_path first_jar unless first_jar.nil?

        raise IOError, 'Java can not be found' unless Which.which('java')
        raise IOError, "No 'plantuml.jar' file could be found" if @plant_uml_jar_file.nil?
        raise IOError, "'#{@plant_uml_jar_file}' does not exist" unless File.exist? @plant_uml_jar_file
      end

      def convert_plantuml_to_svg(plantuml)
        cmd = "java -Djava.awt.headless=true -jar #{@plant_uml_jar_file} -tsvg -pipe"

        plantuml = @themer.apply_theme(plantuml)

        stdout, stderr = Open3.capture3(cmd, stdin_data: plantuml)

        # Circumvention of https://bugs.openjdk.java.net/browse/JDK-8244621
        raise stderr unless stderr.empty? || stderr.include?('CoreText note:')

        svg = strip_xml(stdout)
        wrap(svg)
      end

      private

      def strip_xml(svg)
        xml_prologue_start = '<?xml'
        xml_prologue_end = '?>'

        start_index = svg.index(xml_prologue_start)
        end_index = svg.index(xml_prologue_end, xml_prologue_start.length) \
                  + xml_prologue_end.length

        svg.slice! start_index, end_index

        svg
      end

      def wrap(svg)
        theme_class = @themer.theme_name ? "theme-#{@themer.theme_name}" : ''
        class_name = "plantuml #{theme_class}".strip

        wrapper_element_start = "<div class=\"#{class_name}\">"
        wrapper_element_end = '</div>'

        "#{wrapper_element_start}#{svg}#{wrapper_element_end}"
      end
    end
  end
end
