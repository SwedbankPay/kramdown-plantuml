# frozen_string_literal: true

require_relative 'console_logger'

module Kramdown
  module PlantUml
    # Provides theming support for PlantUML
    class Logger
      def initialize(logger)
        raise ArgumentError, 'logger cannot be nil' if logger.nil?
        raise ArgumentError, 'logger must respond to #debug' unless logger.respond_to? :debug
        raise ArgumentError, 'logger must respond to #info' unless logger.respond_to? :info
        raise ArgumentError, 'logger must respond to #warn' unless logger.respond_to? :warn
        raise ArgumentError, 'logger must respond to #error' unless logger.respond_to? :error

        @logger = logger
      end

      def debug(message)
        @logger.debug(message)
      end

      def info(message)
        @logger.info(message)
      end

      def warn(message)
        @logger.warn(message)
      end

      def error(message)
        @logger.error(message)
      end

      def self.init
        inner = nil

        begin
          require 'jekyll'
          inner = Jekyll.logger
        rescue LoadError
          inner = ConsoleLogger.new
        end

        Logger.new(inner)
      end
    end
  end
end
