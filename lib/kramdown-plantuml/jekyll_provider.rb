# frozen_string_literal: true

require 'json'
require 'English'
require 'rexml/document'
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
          logger.debug_multiline plantuml
        end

        private

        def replace_needles(html)
          html.gsub(/<!--#kramdown-plantuml\.start#-->(?<json>.*?)<!--#kramdown-plantuml\.end#-->/m) do
            json = $LAST_MATCH_INFO[:json]
            return replace_needle(json)
          rescue StandardError => e
            raise e if options.raise_errors?

            logger.error "Error while replacing needle: #{e.inspect}"
          end
        end

        def replace_needle(json)
          hash = JSON.parse(json)
          encoded_plantuml = hash['plantuml']
          plantuml = decode_html_entities(encoded_plantuml)
          options = ::Kramdown::PlantUml::Options.new({ plantuml: hash['options'] })
          diagram = ::Kramdown::PlantUml::Diagram.new(plantuml, options)
          diagram.convert_to_svg
        end

        def decode_html_entities(encoded_plantuml)
          doc = REXML::Document.new "<plantuml>#{encoded_plantuml}</plantuml>"
          doc.root.text
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
