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

      def debug?
        self.class.level == :debug
      end

      class << self
        def init
          inner = nil

          begin
            require 'jekyll'
            inner = Jekyll.logger
          rescue LoadError
            inner = ConsoleLogger.new(level)
          end

          Logger.new(inner)
        end

        def level
          @level ||= level_from_env
        end

        private

        def level_from_env
          return :debug if BoolEnv.new('DEBUG').true?
          return :debug if BoolEnv.new('VERBOSE').true?

          :warn
        end
      end
    end
  end
end
