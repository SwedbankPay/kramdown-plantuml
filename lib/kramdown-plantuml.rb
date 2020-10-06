# frozen_string_literal: true

require 'kramdown-plantuml/version'
require 'kramdown-plantuml/converter'
require 'kramdown_html'

module Kramdown
  module PlantUml
    class Error < StandardError; end
  end
end
