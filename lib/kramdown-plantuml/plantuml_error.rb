# frozen_string_literal: true

module Kramdown
  module PlantUml
    # PlantUML Error
    class PlantUmlError < StandardError
      def initialize(plantuml, stderr)
        message = <<~MESSAGE
          Conversion of the following PlantUML diagram failed:

          #{plantuml}

          The error received from PlantUML was:

          #{stderr}
        MESSAGE

        super message
      end

      def self.should_raise?(stderr)
        !stderr.nil? && !stderr.empty? && \
          # If stderr is not empty, but contains the string 'CoreText note:',
          # the error is caused by a bug in Java, and should be ignored.
          # Circumvents https://bugs.openjdk.java.net/browse/JDK-8244621
          !stderr.include?('CoreText note:')
      end
    end
  end
end
