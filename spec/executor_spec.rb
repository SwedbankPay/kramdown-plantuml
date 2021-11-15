# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/plantuml_diagram'

Executor = ::Kramdown::PlantUml::Executor

describe Executor do
  describe '#initialize' do
    subject { Executor }

    context 'if plantuml.jar is not present', :no_plantuml do
      its(:new) do
        will raise_error(IOError, /No 'plantuml.jar' file could be found/)
      end
    end

    context 'if Java is not installed', :no_java do
      its(:new) do
        will raise_error(IOError, 'Java can not be found')
      end
    end
  end

  describe '#execute' do
    subject { Executor.new }

    context 'diagram is nil' do
      it { expect { subject.execute(nil) }.to raise_error(ArgumentError, 'diagram cannot be nil') }
    end

    context 'diagram is not PlantUmlDiagram' do
      it { expect { subject.execute('') }.to raise_error(ArgumentError, "diagram must be a #{Kramdown::PlantUml::PlantUmlDiagram}") }
    end
  end
end
