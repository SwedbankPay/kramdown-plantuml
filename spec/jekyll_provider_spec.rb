# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/jekyll_provider'

JekyllProvider = ::Kramdown::PlantUml::JekyllProvider

describe JekyllProvider do
  subject { JekyllProvider }

  its (:jekyll) { is_expected.to be_nil }
  its (:install) { is_expected.to be false }
  its (:installed?) { is_expected.to be false }

  describe '#needle' do
    let (:plantuml) { nil }
    let (:options) { nil }
    subject { JekyllProvider.needle(plantuml, options) }

    context 'when plantuml is nil' do
      it { is_expected.to match(/<!--#kramdown-plantuml\.start#-->.*<!--#kramdown-plantuml\.end#-->/m) }
    end

    context 'when plantuml is valid' do
      let (:plantuml) { '@startuml\n\n@enduml' }
      it { is_expected.to match(/<!--#kramdown-plantuml\.start#-->.*@startuml.*@enduml.*<!--#kramdown-plantuml\.end#-->/m) }
    end

    context 'when options has theme' do
      let (:options) { { plantuml: { theme: 'spacelab' } } }
      it { is_expected.to match(/<!--#kramdown-plantuml\.start#-->.*spacelab.*<!--#kramdown-plantuml\.end#-->/m) }
    end
  end
end
