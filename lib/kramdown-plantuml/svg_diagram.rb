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
        transfer_options(plantuml_result)
      end

      def to_s
        return '' if @doc.root.nil?

        wrapper_doc = REXML::Document.new
        wrapper_doc.context[:attribute_quote] = :quote
        wrapper_element = REXML::Element.new('div').tap do |div|
          div.add_attribute 'class', wrapper_class_name
          div.add_element @doc.root
        end

        wrapper_doc.add_element wrapper_element
        wrapper_doc.to_s
      end

      def width
        get_xml_attribute_value(:width)
      end

      def height
        get_xml_attribute_value(:height)
      end

      def style
        get_xml_attribute_value(:style)
      end

      private

      def wrapper_class_name
        theme_class = @source.theme.name ? "theme-#{@source.theme.name}" : ''
        "plantuml #{theme_class}".strip
      end

      def get_xml_attribute_value(attribute_name)
        return nil if @doc.root.nil?

        name = attribute_name.to_s
        value = @doc.root.attributes[name]
        value.nil? || value.none_s? ? :none : value
      end

      def manipulate_xml_attribute(attribute_name, value)
        if value.none_s?
          remove_xml_attribute(attribute_name)
        elsif !value.nil? && value.is_a?(String) && !value.strip.empty?
          set_xml_attribute(attribute_name, value)
        end

        update_style unless attribute_name == :style || style == :none
      end

      def remove_xml_attribute(attribute_name)
        @doc.root.attributes.get_attribute(attribute_name.to_s).remove
      end

      def set_xml_attribute(attribute_name, value)
        name = attribute_name.to_s
        @doc.root.attributes[name] = value
        @style_builder[attribute_name] = value
      end

      def update_style
        style = @style_builder.to_s
        set_xml_attribute(:style, style)
      end

      def transfer_options(plantuml_result)
        return if (options = options(plantuml_result)).nil?

        %i[style width height].each do |attribute|
          options.public_send(attribute).tap do |option_value|
            next if option_value.nil?

            option_value = option_value.to_s.strip

            next if option_value.empty?

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
    end
  end
end
