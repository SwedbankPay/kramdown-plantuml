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
        @logger.debug(options)
        @theme_name, @theme_directory = theme_options(options)
      end

      def apply_theme(plantuml)
        return plantuml if plantuml.nil? || plantuml.empty? || @theme_name.nil? || @theme_name.empty?

        startuml = '@startuml'
        startuml_index = plantuml.index(startuml) + startuml.length

        return plantuml if startuml_index.nil?

        theme_string = "\n!theme #{@theme_name}"
        theme_string << " from #{@theme_directory}" unless @theme_directory.nil?
        theme_string << "\n"

        plantuml.insert startuml_index, theme_string
      end

      private

      def theme_options(options)
        return nil unless options.key?(:theme)

        theme = options[:theme] || {}
        theme_name = theme.key?(:name) ? theme[:name] : nil
        theme_directory = theme.key?(:directory) ? theme[:directory] : nil

        [theme_name, theme_directory]
      end
    end
  end
end
