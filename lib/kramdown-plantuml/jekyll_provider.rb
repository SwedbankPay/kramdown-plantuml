# frozen_string_literal: true

require_relative 'log_wrapper'
require_relative 'jekyll_page_processor'

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
          JekyllPageProcessor.needle(plantuml, options)
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
            processor = JekyllPageProcessor.new(page)

            next unless processor.should_process?

            processor.process(site.dest)
          end
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
