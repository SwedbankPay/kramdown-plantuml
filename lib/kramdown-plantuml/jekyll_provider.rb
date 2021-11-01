# frozen_string_literal: true

require 'json'
require 'English'
require 'htmlentities'
require_relative 'log_wrapper'
require_relative 'diagram'

module Kramdown
  module PlantUml
    # Provides an instance of Jekyll if available.
    module JekyllProvider
      class << self
        def jekyll
          return @jekyll if defined? @jekyll

          @jekyll = load_jekyll
        end

        def install
          return @installed = false if jekyll.nil?

          logger.debug 'Jekyll detected, hooking into :site:post_render'

          Jekyll::Hooks.register :site, :post_render do |site|
            logger.debug ':site:post_render triggered.'

            site.pages.each do |page|
              page.output = replace_needles(page.output)
            end
          end

          @installed = true
        end

        def installed?
          @installed
        end

        def needle(plantuml, options)
          hash = { 'plantuml' => plantuml, 'options' => options.to_h }

          <<~NEEDLE
            <!--#kramdown-plantuml.start#-->
            #{hash.to_json}
            <!--#kramdown-plantuml.end#-->
          NEEDLE
        rescue StandardError => e
          raise e if options.raise_errors?

          puts e
          logger.error 'Error while placing needle.'
          logger.error e.to_s
          logger.plantuml
        end

        private

        def replace_needles(html)
          return html if html.nil? || html.empty? || !html.is_a?(String)

          html.gsub(/<!--#kramdown-plantuml\.start#-->(?<json>.*?)<!--#kramdown-plantuml\.end#-->/m) do
            json = $LAST_MATCH_INFO[:json]
            return replace_needle(json)
          end
        end

        def replace_needle(json)
          hash = JSON.parse(json)
          options_hash = hash['options']
          options = ::Kramdown::PlantUml::Options.new({ plantuml: options_hash })

          begin
            decode_and_convert(hash, options)
          rescue StandardError => e
            raise e if options.raise_errors?

            logger.error 'Error while replacing needle.'
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

        def load_jekyll
          require 'jekyll'
          ::Jekyll
        rescue LoadError
          nil
        end

        def logger
          @logger ||= ::Kramdown::PlantUml::LogWrapper.init
        end
      end
    end
  end
end
