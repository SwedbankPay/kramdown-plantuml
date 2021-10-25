# frozen_string_literal: true

require 'json'
require 'English'
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
          plantuml_options = !options.nil? && options.key?(:plantuml) ? options[:plantuml] : nil
          hash = { 'plantuml' => plantuml, 'options' => plantuml_options }

          <<~NEEDLE
            <!--#kramdown-plantuml.start#-->
            #{hash.to_json}
            <!--#kramdown-plantuml.end#-->
          NEEDLE
        end

        private

        def replace_needles(html)
          html.gsub(/<!--#kramdown-plantuml\.start#-->(?<json>.*?)<!--#kramdown-plantuml\.end#-->/m) do
            json = $LAST_MATCH_INFO[:json]
            hash = JSON.parse(json)
            plantuml = hash['plantuml']
            options = hash['options']
            diagram = ::Kramdown::PlantUml::Diagram.new(plantuml, options)
            return diagram.convert_to_svg
          end
        end

        def load_jekyll
          require 'jekyll'
          ::Jekyll
        rescue LoadError
          nil
        end

        def logger
          @logger ||= ::Kramdown::PlantUml::Logger.init
        end
      end
    end
  end
end
