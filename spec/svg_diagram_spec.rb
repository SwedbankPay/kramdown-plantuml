# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/svg_diagram'

Options ||= Kramdown::PlantUml::Options
SvgDiagram ||= ::Kramdown::PlantUml::SvgDiagram

describe SvgDiagram do
  describe '#initialize' do
    context 'minimal diagram' do
      before(:all) { @svg = Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", Options.new).svg }
      subject { @svg }

      its(:width) { is_expected.not_to be_nil }
      its(:height) { is_expected.not_to be_nil }
      its(:style) { is_expected.not_to be_nil }
    end

    context 'with string options' do
      before(:all) {
        options = Options.new(plantuml: { width: '1337px', height: '1234px', style: 'border: 7px solid red' })
        @svg = Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", options).svg
      }
      subject { @svg }

      its(:width) { is_expected.to eq '1337px' }
      its(:height) { is_expected.to eq '1234px' }
      its(:style) { is_expected.to eq 'border:7px solid red;height:1234px;width:1337px' }
      its(:to_s) {
        is_expected.to have_tag('svg', with: {
          width: '1337px',
          height: '1234px',
          style: 'border:7px solid red;height:1234px;width:1337px'
        })
      }
    end

    context 'with integer options' do
      before(:all) {
        options = Options.new(plantuml: { width: 100, height: 200 })
        @svg = Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", options).svg
      }
      subject { @svg }

      its(:width) { is_expected.to eq '100' }
      its(:height) { is_expected.to eq '200' }
      its(:style) { is_expected.to eq 'height:200;width:100' }
      its(:to_s) {
        is_expected.to have_tag('svg', with: {
          width: '100',
          height: '200',
          style: 'height:200;width:100'
        })
      }
    end

    context 'with all none' do
      before(:all) {
        options = Options.new(plantuml: { width: 'none', height: 'none', style: 'none' })
        @svg = Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", options).svg
      }
      subject { @svg }

      its(:width) { is_expected.to eq :none }
      its(:height) { is_expected.to eq :none }
      its(:style) { is_expected.to eq :none }
      describe '#to_s' do
        subject { @svg.to_s }
        it { is_expected.not_to have_tag('svg[width]') }
        it { is_expected.not_to have_tag('svg[height]') }
        it { is_expected.not_to have_tag('svg[style]') }
      end
    end

    context 'with all :none' do
      before(:all) {
        options = Options.new(plantuml: { width: :none, height: :none, style: :none })
        @svg = Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", options).svg
      }
      subject { @svg }

      its(:width) { is_expected.to eq :none }
      its(:height) { is_expected.to eq :none }
      its(:style) { is_expected.to eq :none }
      describe '#to_s' do
        subject { @svg.to_s }
        it { is_expected.not_to have_tag('svg[width]') }
        it { is_expected.not_to have_tag('svg[height]') }
        it { is_expected.not_to have_tag('svg[style]') }
      end
    end

    context 'with :none width and height' do
      before(:all) {
        options = Options.new(plantuml: { width: :none, height: :none })
        @svg = Kramdown::PlantUml::PlantUmlDiagram.new("@startuml\n@enduml", options).svg
      }
      subject { @svg }

      its(:width) { is_expected.to eq :none }
      its(:height) { is_expected.to eq :none }
      its(:style) { is_expected.not_to be_nil }
      describe '#to_s' do
        subject { @svg.to_s }
        it { is_expected.to have_tag('svg[style]') }
        it { is_expected.not_to have_tag('svg[width]') }
        it { is_expected.not_to have_tag('svg[height]') }
        it { is_expected.not_to include 'width' }
        it { is_expected.not_to include 'height' }
      end
    end

    context 'fails properly' do
      subject { SvgDiagram.new(result) }

      context 'with nil result' do
        let(:result) { nil }
        it { expect { subject }.to raise_error(ArgumentError, 'plantuml_result cannot be nil') }
      end

      context 'result is not PlantUmlResult' do
        let(:result) { '' }
        it { expect { subject }.to raise_error(ArgumentError, "plantuml_result must be a #{Kramdown::PlantUml::PlantUmlResult}") }
      end
    end
  end
end
