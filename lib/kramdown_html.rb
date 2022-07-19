# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'
require_relative 'kramdown-plantuml/log_wrapper'
require_relative 'kramdown-plantuml/plantuml_error'
require_relative 'kramdown-plantuml/options'
require_relative 'kramdown-plantuml/plantuml_diagram'
require_relative 'kramdown-plantuml/converter_extension'

Kramdown::Converter::Html.prepend Kramdown::PlantUml::ConverterExtension
