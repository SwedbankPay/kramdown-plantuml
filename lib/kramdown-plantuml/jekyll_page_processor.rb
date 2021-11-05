# frozen_string_literal: true

require 'htmlentities'
require 'json'
require_relative 'log_wrapper'

module Kramdown
  module PlantUml
    # Processes Jekyll pages.
    class JekyllPageProcessor
      PROCESSED_KEY = :kramdown_plantuml_processed

      def initialize(page)
        raise ArgumentError, 'page cannot be nil' if page.nil?

        puts page.class

        @page = page
      end

      def process(site_destination_directory)
        @page.output = do_process
        @page.data[PROCESSED_KEY] = true
        @page.write(site_destination_directory)
      end

      def should_process?
        return false unless @page.output_ext == '.html'

        if !@page.data.nil? && @page.data.key?(PROCESSED_KEY) && @page.data[PROCESSED_KEY]
          logger.debug "Skipping #{@page.path} because it has already been processed."
          return false
        end

        true
      end

      class << self
        def needle(plantuml, options)
          hash = { 'plantuml' => plantuml, 'options' => options.to_h }

          <<~NEEDLE
            <!--#kramdown-plantuml.start#-->
            #{hash.to_json}
            <!--#kramdown-plantuml.end#-->
          NEEDLE
        rescue StandardError => e
          raise e if options.nil? || options.raise_errors?

          logger.error 'Error while placing needle.'
          logger.error e.to_s
          logger.debug_multiline plantuml
        end

        def logger
          @logger ||= ::Kramdown::PlantUml::LogWrapper.init
        end
      end

      private

      def do_process
        logger.debug "Replacing Jekyll needles in #{@page.path}"

        html = @page.output

        return html if html.nil? || html.empty? || !html.is_a?(String)

        html.gsub(/<!--#kramdown-plantuml\.start#-->(?<json>.*?)<!--#kramdown-plantuml\.end#-->/m) do
          json = $LAST_MATCH_INFO ? $LAST_MATCH_INFO[:json] : nil
          replace_needle(json) unless json.nil?
        end
      end

      def replace_needle(json)
        logger.debug 'Replacing Jekyll needle.'

        needle_hash = JSON.parse(json)
        options_hash = needle_hash['options']
        options = ::Kramdown::PlantUml::Options.new({ plantuml: options_hash })

        begin
          decode_and_convert(needle_hash, options)
        rescue StandardError => e
          raise e if options.raise_errors?

          logger.error 'Error while replacing Jekyll needle.'
          logger.error e.to_s
          logger.debug_multiline json
        end
      end

      def decode_and_convert(hash, options)
        encoded_plantuml = hash['plantuml']
        plantuml = HTMLEntities.new.decode encoded_plantuml
        diagram = ::Kramdown::PlantUml::Diagram.new(plantuml, options)
        diagram.convert_to_svg
      end

      def logger
        @logger ||= ::Kramdown::PlantUml::LogWrapper.init
      end
    end
  end
end
