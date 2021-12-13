# frozen_string_literal: true

require_relative 'log_wrapper'

module Kramdown
  module PlantUml
    # Provides an instance of Jekyll if available.
    module JekyllProvider
      class << self
        attr_reader :site_source_dir

        def jekyll
          return @jekyll if defined? @jekyll

          @jekyll = load_jekyll
        end

        private

        def find_site_source_dir
          if jekyll.sites.nil? || jekyll.sites.empty?
            logger.warn 'Jekyll detected, but no sites found.'
            return nil
          end

          @site_source_dir = jekyll.sites.first.source
          logger.debug "Jekyll detected, using '#{@site_source_dir}' as base directory."
          @site_source_dir
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
