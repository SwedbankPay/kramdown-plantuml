# frozen_string_literal: false

require_relative 'logger'

module Kramdown
  module PlantUml
    # Provides theming support for PlantUML
    class Theme
      attr_reader :name, :directory

      def initialize(options = {})
        @logger = Logger.init
        @name, @directory = theme_options(options)
      end

      def apply(plantuml)
        if plantuml.nil? || !plantuml.is_a?(String) || plantuml.empty?
          @logger.debug 'Empty diagram or not a String.'
          return plantuml
        end

        if @name.nil? || @name.empty?
          @logger.debug 'No theme to apply.'
          return plantuml
        end

        theme(plantuml)
      end

      private

      def theme_options(options)
        options = symbolize_keys(options)

        @logger.debug "Options: #{options}"

        return nil if options.nil? || !options.key?(:theme)

        theme = options[:theme] || {}
        name = theme.key?(:name) ? theme[:name] : nil
        directory = theme.key?(:directory) ? theme[:directory] : nil

        [name, directory]
      end

      def symbolize_keys(options)
        return options if options.nil?

        array = options.map do |key, value|
          value = value.is_a?(Hash) ? symbolize_keys(value) : value
          [key.to_sym, value]
        end

        array.to_h
      end

      def theme(plantuml)
        startuml = '@startuml'
        startuml_index = plantuml.index(startuml) + startuml.length

        return plantuml if startuml_index.nil?

        theme_string = "\n!theme #{@name}"
        theme_string << " from #{@directory}" unless @directory.nil?

        @logger.debug "Applying #{theme_string.strip}"

        /@startuml.*/.match(plantuml) do |match|
          return plantuml.insert match.end(0), theme_string
        end

        plantuml
      end
    end
  end
end
