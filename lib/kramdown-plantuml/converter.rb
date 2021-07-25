# frozen_string_literal: true

require_relative 'version'
require_relative 'themer'
require_relative 'plantuml_error'
require_relative 'logger'
require_relative 'executor'

module Kramdown
  module PlantUml
    # Converts PlantUML markup to SVG
    class Converter
      def initialize(options = {})
        @themer = Themer.new(options)
        @logger = Logger.init
        @executor = Executor.new
      end

      def convert_plantuml_to_svg(plantuml)
        plantuml = @themer.apply_theme(plantuml)
        result = @executor.execute(plantuml)
        result.validate(plantuml)
        svg = strip_xml(result.stdout)
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
