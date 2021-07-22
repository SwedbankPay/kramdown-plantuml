# frozen_string_literal: true

require 'kramdown_html'

describe Kramdown::Converter::Html do
  subject {
    plantuml_content = File.read(File.join(__dir__, 'diagram.plantuml'))
    document = "```plantuml\n@startuml\n@enduml\n```"
    Kramdown::Document.new(document, input: 'GFM').to_html
  }

  it {
    is_expected.to include('class="plantuml">')
  }
end
