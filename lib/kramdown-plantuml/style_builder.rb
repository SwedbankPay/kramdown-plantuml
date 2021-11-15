# frozen_string_literal: true

module Kramdown
  module PlantUml
    # Builds a CSS style string from a hash of style properties.
    class StyleBuilder
      def initialize
        @hash = {}
      end

      def set(key, value)
        case key
        when :width, :height
          @hash[key] = value
        else
          self.style = value
        end
      end

      def to_s
        @hash.map { |key, value| "#{key}:#{value}" }.join(';')
      end

      private

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
