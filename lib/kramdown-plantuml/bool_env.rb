# frozen_string_literal: true

module Kramdown
  module PlantUml
    # Converts envrionment variables to boolean values
    class BoolEnv
      TRUTHY_VALUES = %w[t true yes y 1].freeze
      FALSEY_VALUES = %w[f false n no 0].freeze

      def initialize(name)
        @name = name
        @value = ENV.key?(name) ? ENV[name] : nil
        @value = @value.to_s.downcase unless @value.nil?
      end

      def true?
        return true if TRUTHY_VALUES.include?(@value)
        return false if FALSEY_VALUES.include?(@value) || @value.nil? || value.empty?

        raise "The value '#{@value}' of '#{@name}' can't be converted to a boolean"
      end
    end
  end
end
