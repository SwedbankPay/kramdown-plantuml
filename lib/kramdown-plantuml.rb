# frozen_string_literal: true

require_relative 'kramdown_html'
require_relative 'kramdown-plantuml/jekyll_provider'

::Kramdown::PlantUml::JekyllProvider.install
