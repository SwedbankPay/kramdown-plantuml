# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/options'
require 'kramdown-plantuml/jekyll_page_processor'

Options ||= Kramdown::PlantUml::Options
JekyllPageProcessor = ::Kramdown::PlantUml::JekyllPageProcessor

describe JekyllPageProcessor do
  let(:page) do
    page = double('page')
    allow(page).to receive(:output).and_return(output)
    allow(page).to receive(:output=)
    allow(page).to receive(:output_ext).and_return(output_ext)
    allow(page).to receive(:data).and_return({})
    allow(page).to receive(:write)
    allow(page).to receive(:path).and_return(File.join(__dir__, 'page.md'))
    page
  end

  subject { JekyllPageProcessor.new(page) }

  describe '#initialize' do
    context 'when page is nil' do
      let(:page) { nil }
      it { expect { subject }.to raise_error(ArgumentError, 'page cannot be nil') }
    end
  end

  describe '#needle' do
    subject { JekyllPageProcessor.needle(plantuml, options) }

    context 'with nil :options' do
      let(:options) { nil }
      let(:plantuml) { "@startuml\n@enduml" }

      it do
        is_expected.to eq <<~NEEDLE
          <!--#kramdown-plantuml.start#-->
          {"plantuml":"@startuml\\n@enduml","options":{}}
          <!--#kramdown-plantuml.end#-->
        NEEDLE
      end
    end

    context 'with nil :plantuml' do
      let(:options) { Options.new }
      let(:plantuml) { nil }

      it do
        is_expected.to eq <<~NEEDLE
          <!--#kramdown-plantuml.start#-->
          {"plantuml":null,"options":{}}
          <!--#kramdown-plantuml.end#-->
        NEEDLE
      end
    end

    context 'with valid :options and :plantuml' do
      let(:options) { { theme: { name: 'custom' } } }
      let(:plantuml) { "@startuml\n@enduml" }

      it do
        is_expected.to eq <<~NEEDLE
          <!--#kramdown-plantuml.start#-->
          {"plantuml":"@startuml\\n@enduml","options":{"theme":{"name":"custom"}}}
          <!--#kramdown-plantuml.end#-->
        NEEDLE
      end
    end
  end

  describe '#process' do
    before { subject.process(__dir__) }

    context 'with HTML output' do
      let(:output) { '<h1 id="hello">Hello</h1>' }
      let(:output_ext) { '.html' }
      its(:should_process?) { is_expected.to eq false }
      it { expect(page.output).to eq output }
    end
  end

  describe '#should_process?' do
    context 'with HTML output' do
      let(:output) { '<h1 id="hello">Hello</h1>' }
      let(:output_ext) { '.html' }
      its(:should_process?) { is_expected.to eq true }
      it { expect(page.output).to eq output }
    end

    context 'with CSS output' do
      let(:output) { 'body { display: none }' }
      let(:output_ext) { '.css' }
      its(:should_process?) { is_expected.to eq false }
    end
  end
end
