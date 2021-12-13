# frozen_string_literal: false

require_relative 'options'
require_relative 'log_wrapper'
require_relative 'jekyll_provider'

module Kramdown
  module PlantUml
    # Provides theming support for PlantUML
    class Theme
      attr_reader :name, :directory, :scale

      def initialize(options)
        raise ArgumentError, 'options cannot be nil' if options.nil?
        raise ArgumentError, "options must be a '#{Options}'." unless options.is_a?(Options)

        @raise_errors = options.raise_errors?
        @logger = LogWrapper.init
        @name = options.theme_name
        @scale = options.scale
        @directory = resolve options.theme_directory
      end

      def apply(plantuml)
        if plantuml.nil? || !plantuml.is_a?(String) || plantuml.empty?
          @logger.debug 'Empty diagram or not a String.'
          return plantuml
        end

        theme(plantuml)
      end

      private

      def resolve(directory)
        jekyll = JekyllProvider

        return directory if directory.nil? || directory.empty?

        directory = File.absolute_path(directory, jekyll.site_source_dir)

        log_or_raise "The theme directory '#{directory}' cannot be found" unless Dir.exist?(directory)

        theme_path = File.join(directory, "puml-theme-#{@name}.puml")

        log_or_raise "The theme '#{theme_path}' cannot be found" unless File.exist?(theme_path)

        directory
      end

      def log_or_raise(message)
        raise IOError, message if @raise_errors

        @logger.warn message
      end

      def theme(plantuml)
        theme_string = build_theme_string

        if theme_string.empty?
          @logger.debug 'No theme to apply.'
          return plantuml
        end

        @logger.debug "Applying #{theme_string.strip}"

        /@startuml.*/.match(plantuml) do |match|
          return plantuml.insert match.end(0), theme_string
        end

        plantuml.strip
      end

      def build_theme_string
        theme_string = ''

        unless @name.nil? || @name.empty?
          theme_string << "\n!theme #{@name}"
          theme_string << " from #{@directory}" unless @directory.nil?
        end

        theme_string << "\nscale #{@scale}" unless @scale.nil?
        theme_string
      end
    end
  end
end
