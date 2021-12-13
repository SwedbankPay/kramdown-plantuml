# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/options'
require 'kramdown-plantuml/plantuml_error'

Options ||= Kramdown::PlantUml::Options
PlantUmlDiagram ||= Kramdown::PlantUml::PlantUmlDiagram
PlantUmlError = Kramdown::PlantUml::PlantUmlError
PlantUmlResult = Kramdown::PlantUml::PlantUmlResult

describe PlantUmlError do
  describe '#initialize' do
    let(:plantuml) { 'some plantuml' }
    let(:options) { Options.new }
    let(:exitcode) { 1 }
    let(:diagram) { PlantUmlDiagram.new(plantuml, options) }
    let(:result) { PlantUmlResult.new(diagram, '', stderr, exitcode) }
    subject { PlantUmlError.new(result) }

    context 'message is expected' do
      let(:stderr) { 'some stderr' }

      its(:message) {
        is_expected.to match(/some plantuml/)
        is_expected.to match(/some stderr/)
        is_expected.to match(/Exit code: 1/)
      }
    end

    context 'nil result' do
      let(:result) { nil }
      it { expect { subject }.to raise_error(ArgumentError, 'result cannot be nil') }
    end

    context "result is not a #{PlantUmlResult}" do
      let(:result) { {} }
      it { expect { subject }.to raise_error(ArgumentError, "result must be a #{PlantUmlResult}") }
    end

    context 'non-existent theme' do
      let(:options) { Options.new({ plantuml: { theme: { name: 'xyz', directory: 'assets' }, raise_errors: false } }) }
      let(:stderr) { <<~STDERR
        java.lang.NullPointerException
          at java.base/java.io.Reader.<init>(Reader.java:167)
          at java.base/java.io.BufferedReader.<init>(BufferedReader.java:101)
          at java.base/java.io.BufferedReader.<init>(BufferedReader.java:116)
          at net.sourceforge.plantuml.preproc.ReadLineReader.<init>(ReadLineReader.java:57)
          at net.sourceforge.plantuml.preproc.ReadLineReader.create(ReadLineReader.java:73)
          at net.sourceforge.plantuml.tim.EaterTheme.getTheme(EaterTheme.java:97)
          at net.sourceforge.plantuml.tim.TContext.executeTheme(TContext.java:575)
          at net.sourceforge.plantuml.tim.TContext.executeOneLineNotSafe(TContext.java:289)
          at net.sourceforge.plantuml.tim.TContext.executeOneLineSafe(TContext.java:270)
          at net.sourceforge.plantuml.tim.TContext.executeLines(TContext.java:241)
          at net.sourceforge.plantuml.tim.TimLoader.load(TimLoader.java:66)
          at net.sourceforge.plantuml.BlockUml.<init>(BlockUml.java:124)
          at net.sourceforge.plantuml.BlockUmlBuilder.init(BlockUmlBuilder.java:123)
          at net.sourceforge.plantuml.BlockUmlBuilder.<init>(BlockUmlBuilder.java:74)
          at net.sourceforge.plantuml.SourceStringReader.<init>(SourceStringReader.java:88)
          at net.sourceforge.plantuml.Pipe.managePipe(Pipe.java:84)
          at net.sourceforge.plantuml.Run.managePipe(Run.java:356)
          at net.sourceforge.plantuml.Run.main(Run.java:176)
        STDERR
      }

      its(:message) {
        is_expected.to match(/theme 'xyz' can't be found in the directory '.*assets'/)
        is_expected.to match(/The error received from PlantUML was:/)
      }
    end
  end
end
