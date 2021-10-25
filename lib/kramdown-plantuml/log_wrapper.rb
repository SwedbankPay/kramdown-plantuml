# frozen_string_literal: true

require_relative 'console_logger'
require_relative 'jekyll_provider'

module Kramdown
  module PlantUml
    # Logs stuff
    class LogWrapper
      def initialize(logger)
        raise ArgumentError, 'logger cannot be nil' if logger.nil?
        raise ArgumentError, 'logger must respond to #debug' unless logger.respond_to? :debug
        raise ArgumentError, 'logger must respond to #info' unless logger.respond_to? :info
        raise ArgumentError, 'logger must respond to #warn' unless logger.respond_to? :warn
        raise ArgumentError, 'logger must respond to #error' unless logger.respond_to? :error

        @logger = logger
      end

      def debug(message)
        write :debug, message
      end

      def debug_multiline(multiline_string)
        return if multiline_string.nil? || multiline_string.empty?

        lines = multiline_string.lines
        lines.each do |line|
          write :debug, line.rstrip
        end
      end

      def info(message)
        write :info, message
      end

      def warn(message)
        write :warn, message
      end

      def error(message)
        write :error, message
      end

      def debug?
        self.class.level == :debug
      end

      def level
        @level ||= level_from_logger || self.class.env
      end

      class << self
        def init
          inner = JekyllProvider.jekyll ? JekyllProvider.jekyll.logger : nil
          inner ||= ConsoleLogger.new(level)
          new inner
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

      private

      def write(level, message)
        @logger.public_send(level, " kramdown-plantuml: #{message}")
      end

      def level_from_logger
        return @logger.level if @logger.respond_to? :level

        nil
      end
    end
  end
end
