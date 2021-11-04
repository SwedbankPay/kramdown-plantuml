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
        attr_reader :site_destination_dir

        def jekyll
          return @jekyll if defined? @jekyll

          @jekyll = load_jekyll
        end

        def install
          return @installed = false if jekyll.nil?

          find_site_destination_dir
          register_hook
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

          logger.error 'Error while placing needle.'
          logger.error e.to_s
          logger.debug_multiline plantuml
        end

        private

        def find_site_destination_dir
          if jekyll.sites.nil? || jekyll.sites.empty?
            logger.debug 'Jekyll detected, hooking into :site:post_write.'
            return nil
          end

          @site_destination_dir = jekyll.sites.first.dest
          logger.debug "Jekyll detected, hooking into :site:post_write of '#{@site_destination_dir}'."
          @site_destination_dir
        end

        def register_hook
          Jekyll::Hooks.register :site, :post_write do |site|
            site_post_write(site)
          end
        end

        def site_post_write(site)
          logger.debug 'Jekyll:site:post_write triggered.'
          @site_destination_dir ||= site.dest

          site.pages.each do |page|
            next unless should_process? page

            page.output = replace_needles(page)
            page.data[:kramdown_plantuml_needle_replaced] = true
            page.write(site.dest)
          end
        end

        def should_process?(page)
          return false unless page.output_ext == '.html'

          if !page.data.nil? && page.data.key?(:kramdown_plantuml_needle_replaced) && page.data[:kramdown_plantuml_needle_replaced]
            logger.debug "Skipping #{page.path} because it has already been processed."
            return false
          end

          true
        end

        def replace_needles(page)
          logger.debug "Replacing Jekyll needles in #{page.path}"

          html = page.output

          return html if html.nil? || html.empty? || !html.is_a?(String)

          html.gsub(/<!--#kramdown-plantuml\.start#-->(?<json>.*?)<!--#kramdown-plantuml\.end#-->/m) do
            json = $LAST_MATCH_INFO[:json]
            replace_needle(json)
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
