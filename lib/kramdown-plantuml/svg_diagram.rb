# frozen_string_literal: true

require 'rexml/document'
require_relative 'none_s'
require_relative 'style_builder'
require_relative 'plantuml_diagram'

module Kramdown
  module PlantUml
    # A diagram in SVG format.
    class SvgDiagram
      def initialize(plantuml_result)
        raise ArgumentError, 'plantuml_result cannot be nil' if plantuml_result.nil?
        raise ArgumentError, "plantuml_result must be a #{PlantUmlResult}" unless plantuml_result.is_a?(PlantUmlResult)

        plantuml_result.validate!
        svg = plantuml_result.stdout
        @doc = REXML::Document.new svg
        @source = plantuml_result.plantuml_diagram
        @style_builder = StyleBuilder.new
        transfer_options(%i[style width height], plantuml_result)
      end

      def to_s
        wrap(@doc.root.to_s)
      end

      def width
        get_xml_attribute(:width)
      end

      def height
        get_xml_attribute(:height)
      end

      def style
        get_xml_attribute(:style)
      end

      private

      def get_xml_attribute(attribute_name)
        return nil if @doc.root.nil?

        name = attribute_name.to_s
        value = @doc.root.attributes[name]
        value.nil? || value.none_s? ? :none : value
      end

      def manipulate_xml_attribute(attribute_name, value)
        if value.none_s?
          @doc.root.attributes.get_attribute(attribute_name.to_s).remove
        elsif !value.nil? && value.is_a?(String) && !value.strip.empty?
          set_xml_attribute(attribute_name, value)
        end
      end

      def set_xml_attribute(attribute_name, value)
        name = attribute_name.to_s
        @doc.root.attributes[name] = value
        @style_builder[attribute_name] = value

        return if attribute_name == :style || style == :none

        style = @style_builder.to_s

        set_xml_attribute(:style, style)
      end

      def transfer_options(attributes, plantuml_result)
        return if (options = options(plantuml_result)).nil?

        attributes.each do |attribute|
          options.public_send(attribute).tap do |option_value|
            next if option_value.nil?

            option_value = option_value.to_s

            next if option_value.strip.empty?

            manipulate_xml_attribute(attribute, option_value)
          end
        end
      end

      def options(plantuml_result)
        return nil if @doc.root.nil? \
          || plantuml_result.nil? \
          || plantuml_result.plantuml_diagram.nil?

        plantuml_result.plantuml_diagram.options
      end

      def wrap(svg)
        return svg if svg.nil? || svg.empty?

        # TODO: Replace with proper XML DOM operations.
        theme_class = @source.theme.name ? "theme-#{@source.theme.name}" : ''
        class_name = "plantuml #{theme_class}".strip

        wrapper_element_start = "<div class=\"#{class_name}\">"
        wrapper_element_end = '</div>'

        "#{wrapper_element_start}#{svg}#{wrapper_element_end}"
      end
    end
  end
end
