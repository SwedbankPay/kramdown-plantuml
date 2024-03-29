# frozen_string_literal: true

require_relative 'none_s'
require_relative 'log_wrapper'

module Kramdown
  module PlantUml
    # Options for PlantUML processing
    class Options
      attr_reader :theme_name, :theme_directory, :width, :height, :style, :scale

      def initialize(options_hash = {})
        @logger = LogWrapper.init
        @options = massage(options_hash) || {}
        @raise_errors = extract_raise_errors(@options)
        extract_theme_options(@options)
        extract_style_options(@options)
      end

      def raise_errors?
        @raise_errors
      end

      def to_h
        @options
      end

      private

      def boolean(value, default_value)
        return value if [true, false].include? value
        return default_value if value.nil?

        s = value.to_s.strip
        return true if %w[true yes 1].select { |v| v.casecmp(s).zero? }.any?
        return false if %w[false no 0].select { |v| v.casecmp(s).zero? }.any?

        default_value
      end

      def extract_plantuml_options(options_hash)
        return options_hash[:plantuml] if options_hash.key?(:plantuml)
        return options_hash['plantuml'] if options_hash.key?('plantuml')

        {}
      end

      def extract_theme_options(options)
        return if options.nil? || options.empty? || !options.key?(:theme)

        theme = options[:theme]

        unless theme.is_a?(Hash)
          @logger.warn ":theme is not a Hash: #{theme}"
          return
        end

        @theme_name = theme.key?(:name) ? theme[:name] : nil
        @theme_directory = theme.key?(:directory) ? theme[:directory] : nil
      end

      def extract_raise_errors(options)
        return true if options.nil? || options.empty? || !options.key?(:raise_errors)

        raise_errors = options[:raise_errors]
        boolean(raise_errors, true)
      end

      def extract_style_options(options)
        return if options.nil? || options.empty?

        set_instance_property(:width, options)
        set_instance_property(:height, options)
        set_instance_property(:style, options)
        set_instance_property(:scale, options)
      end

      def set_instance_property(key, options)
        return unless options.key? key

        value = options[key]
        value = :none if value.none_s?
        prop_name = "@#{key}".to_sym
        instance_variable_set(prop_name, value)
      end

      def massage(options_hash)
        if options_hash.nil? || !options_hash.is_a?(Hash) || options_hash.empty?
          @logger.debug 'No options provided'
          return {}
        end

        plantuml_options = extract_plantuml_options(options_hash)
        symbolize_keys(plantuml_options)
      end

      def symbolize_keys(options)
        return options if options.nil? || options.empty?

        array = options.map do |key, value|
          value = value.is_a?(Hash) ? symbolize_keys(value) : value
          [key.to_sym, value]
        end

        array.to_h
      end
    end
  end
end
