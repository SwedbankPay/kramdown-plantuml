# frozen_string_literal: false

module Kramdown
  module PlantUml
    # Provides theming support for PlantUML
    class Themer
      attr_reader :theme_name, :theme_directory

      def initialize(options = {})
        @theme_name, @theme_directory = theme_options(options)
      end

      def apply_theme(plantuml)
        return plantuml if plantuml.nil? || plantuml.empty?
        return plantuml if @theme_name.nil? || @theme_name.empty?

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
