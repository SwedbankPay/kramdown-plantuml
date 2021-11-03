# frozen_string_literal: false

require_relative 'options'
require_relative 'log_wrapper'
require_relative 'jekyll_provider'

module Kramdown
  module PlantUml
    # Provides theming support for PlantUML
    class Theme
      attr_reader :name, :directory

      def initialize(options)
        raise ArgumentError, 'options cannot be nil' if options.nil?
        raise ArgumentError, "options must be a '#{Options}'." unless options.is_a?(Options)

        @raise_errors = options.raise_errors?
        @logger = LogWrapper.init
        @name = options.theme_name
        @directory = resolve options.theme_directory
      end

      def apply(plantuml)
        if plantuml.nil? || !plantuml.is_a?(String) || plantuml.empty?
          @logger.debug 'Empty diagram or not a String.'
          return plantuml
        end

        if @name.nil? || @name.empty?
          @logger.debug 'No theme to apply.'
          return plantuml.strip
        end

        theme(plantuml)
      end

      private

      def resolve(directory)
        jekyll = JekyllProvider

        return directory if directory.nil? || directory.empty? || !jekyll.installed?

        directory = File.absolute_path(directory, jekyll.site_destination_dir)

        log_or_raise "The theme directory '#{directory}' cannot be found" unless Dir.exist?(directory)

        theme_path = File.join(directory, "puml-theme-#{@name}.puml")

        log_or_raise "The theme '#{theme_path}' cannot be found" unless File.exist?(theme_path)

        directory
      end

      def log_or_raise(message)
        raise IOError, message if @raise_errors

        logger.warn message
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

        plantuml.strip
      end
    end
  end
end
