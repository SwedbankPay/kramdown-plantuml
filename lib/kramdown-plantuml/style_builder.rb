# frozen_string_literal: true

require_relative 'none_s'

module Kramdown
  module PlantUml
    # Builds a CSS style string from a hash of style properties.
    class StyleBuilder
      def initialize
        @hash = {}
      end

      def []=(key, value)
        return if key.nil?

        case key
        when :width, :height
          if none(value)
            puts "Deleting :#{key}."
            @hash.delete(key)
          else
            puts "Setting :#{key} to '#{value}'."
            @hash[key] = value
          end
        else
          self.style = value
        end
      end

      def to_s
        @hash.sort_by { |key, _| key }.map { |key, value| "#{key}:#{value}" }.join(';')
      end

      private

      def none(value)
        return true if value.nil?

        value_s = value.to_s.strip

        return true if value_s.empty? || value.none_s?

        false
      end

      def style=(style)
        return if style.nil? || style.strip.empty?

        style.split(';').each do |pair|
          key, value = pair.split(':')
          key = key.strip.to_sym
          value = value.strip
          @hash[key] = value
        end
      end
    end
  end
end
