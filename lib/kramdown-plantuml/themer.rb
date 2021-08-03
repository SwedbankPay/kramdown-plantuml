# frozen_string_literal: false

require_relative 'hash'
require_relative 'logger'

module Kramdown
  module PlantUml
    # Provides theming support for PlantUML
    class Themer
      attr_reader :theme_name, :theme_directory

      def initialize(options = {})
        options = options.symbolize_keys
        @logger = Logger.init
        @logger.debug "kramdown-plantuml: Options: #{options}"
        @theme_name, @theme_directory = theme_options(options)
      end

      def apply_theme(plantuml)
        if plantuml.nil? || plantuml.empty?
          @logger.debug 'kramdown-plantuml: Empty diagram.'
          return plantuml
        end

        if @theme_name.nil? || @theme_name.empty?
          @logger.debug 'kramdown-plantuml: No theme to apply.'
          return plantuml
        end

        theme(plantuml)
      end

      private

      def theme_options(options)
        return nil unless options.key?(:theme)

        theme = options[:theme] || {}
        theme_name = theme.key?(:name) ? theme[:name] : nil
        theme_directory = theme.key?(:directory) ? theme[:directory] : nil

        [theme_name, theme_directory]
      end

      def theme(plantuml)
        startuml = '@startuml'
        startuml_index = plantuml.index(startuml) + startuml.length

        return plantuml if startuml_index.nil?

        theme_string = "\n!theme #{@theme_name}"
        theme_string << " from #{@theme_directory}" unless @theme_directory.nil?

        @logger.debug "kramdown-plantuml: Applying #{theme_string}"

        /@startuml.*/.match(plantuml) do |match|
          return plantuml.insert match.end(0), theme_string
        end

        plantuml
      end
    end
  end
end
