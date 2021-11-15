# frozen_string_literal: true

require_relative 'plantuml_result'

module Kramdown
  module PlantUml
    # PlantUML Error
    class PlantUmlError < StandardError
      def initialize(result)
        raise ArgumentError, 'result cannot be nil' if result.nil?
        raise ArgumentError, "result must be a #{PlantUmlResult}" unless result.is_a?(PlantUmlResult)

        super create_message(result)
      end

      private

      def create_message(result)
        header = header(result).gsub("\n", ' ').strip
        plantuml = plantuml(result)
        result = result(result)
        message = <<~MESSAGE
          #{header}

          #{plantuml}

          #{result}
        MESSAGE

        message.strip
      end

      def header(result)
        if theme_not_found?(result) && !result.plantuml_diagram.nil? && !result.plantuml_diagram.theme.nil?
          return <<~HEADER
            Conversion of the following PlantUML result failed because the
            theme '#{result.plantuml_diagram.theme.name}' can't be found in the directory
            '#{result.plantuml_diagram.theme.directory}':
          HEADER
        end

        'Conversion of the following PlantUML result failed:'
      end

      def theme_not_found?(result)
        !result.nil? \
        && !result.stderr.nil? \
        && result.stderr.include?('NullPointerException') \
        && result.stderr.include?('getTheme')
      end

      def plantuml(result)
        return nil if result.nil? || result.plantuml_diagram.nil?

        result.plantuml_diagram.plantuml
      end

      def result(result)
        return nil if result.nil?

        <<~RESULT
          The error received from PlantUML was:

          Exit code: #{result.exitcode}
          #{result.stderr}
        RESULT
      end
    end
  end
end
