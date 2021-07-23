# frozen_string_literal: true

require_relative 'kramdown-plantuml/version'
require_relative 'kramdown-plantuml/converter'
require_relative 'kramdown_html'

module Kramdown
  module PlantUml
    class PlantUmlError < StandardError; end
  end
end
