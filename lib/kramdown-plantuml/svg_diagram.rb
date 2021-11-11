# frozen_string_literal: true

require 'rexml/document'
require_relative 'plantuml_diagram'

module Kramdown
  module PlantUml
    # A diagram in SVG format.
    class SvgDiagram
      attr_accessor :width, :height, :style

      def initialize(plantuml_result)
        raise ArgumentError, 'plantuml_result cannot be nil' if plantuml_result.nil?
        raise ArgumentError, "plantuml_result must be a #{PlantUmlResult}" unless plantuml_result.is_a?(PlantUmlResult)

        plantuml_result.validate!
        svg = plantuml_result.stdout
        @doc = REXML::Document.new svg
        @source = plantuml_result.plantuml_diagram
      end

      def to_s
        root = tweak_attributes(@doc.root)
        wrap(root.to_s)
      end

      private

      def wrap(svg)
        return svg if svg.nil? || svg.empty?

        # TODO: Replace with proper XML DOM operations.
        theme_class = @source.theme.name ? "theme-#{@source.theme.name}" : ''
        class_name = "plantuml #{theme_class}".strip

        wrapper_element_start = "<div class=\"#{class_name}\">"
        wrapper_element_end = '</div>'

        "#{wrapper_element_start}#{svg}#{wrapper_element_end}"
      end

      def tweak_attributes(element)
        return element
        # return element if element.nil? || !element.is_a?(REXML::Element)

        # TODO: Figure out how to configure removal of the attributes, we can't use nil
        element.attributes.get_attribute('width').remove if @width.nil?
        element.attributes.get_attribute('height').remove if @height.nil?
        element.attributes.get_attribute('style').remove if @style.nil?
        element
      end
    end
  end
end
