# frozen_string_literal: true

require_relative 'bool_env'

module Kramdown
  module PlantUml
    # Logs to $stdout and $stderr
    class ConsoleLogger
      LOG_LEVELS = %i[debug info warn error].freeze

      def initialize(level)
        @configured_log_level = level
      end

      def debug(message)
        write(:debug, message)
      end

      def info(message)
        write(:info, message)
      end

      def warn(message)
        write(:warn, message)
      end

      def error(message)
        write(:error, message)
      end

      private

      def write(level, message)
        return false unless write_message?(level)

        pipe = pipe_for(level)
        pipe.write("\n#{message}")
      end

      def write_message?(level_of_message)
        LOG_LEVELS.index(@configured_log_level) <= LOG_LEVELS.index(level_of_message)
      end

      def pipe_for(level)
        case level
        when :debug, :info
          $stdout
        when :warn, :error
          $stderr
        else
          raise ArgumentError, "Unknown log level '#{level}'."
        end
      end
    end
  end
end
