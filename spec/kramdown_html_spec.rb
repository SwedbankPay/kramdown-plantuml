# frozen_string_literal: true

require 'kramdown_html'

describe Kramdown::Converter::Html do
  context 'valid PlantUML' do
    let (:options) { { input: 'GFM' } }

    subject do
      document = "```plantuml\n@startuml\n@enduml\n```"
      Kramdown::Document.new(document, options).to_html
    end

    context 'clean' do
      it {
        is_expected.to include('class="plantuml">')
      }
    end

    context 'built-in theme' do
      let (:options) {
        {
          input: 'GFM',
          plantuml: {
            theme: {
              name: 'spacelab',
            }
          }
        }
      }

      it {
        is_expected.to include('class="plantuml theme-spacelab">')
      }

      it 'has theme metadata', :debug do
        is_expected.to include("!theme spacelab")
      end
    end

    context 'custom theme' do
      examples_dir = File.join __dir__, 'examples'

      let (:options) {
        {
          input: 'GFM',
          plantuml: {
            theme: {
              name: 'c2a3b0',
              directory: examples_dir,
            }
          }
        }
      }

      it {
        is_expected.to include('class="plantuml theme-c2a3b0">')
      }

      it 'has theme metadata', :debug do
        is_expected.to include("!theme c2a3b0 from #{examples_dir}")
      end

      it {
        # Taken from `skinparam backgroundColor red` in the theme.
        is_expected.to include('background:#FF0000;')
      }
    end
  end

  context 'invalid PlantUML' do
    let(:plantuml) { "```plantuml\n@startuml\n###INVALID###\n@enduml\n```" }

    it {
      expect { Kramdown::Document.new(plantuml, input: 'GFM').to_html }.to \
        raise_error(Kramdown::PlantUml::PlantUmlError, /###INVALID###/)
    }
  end
end
