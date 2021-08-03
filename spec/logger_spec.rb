# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/logger'
require 'kramdown-plantuml/console_logger'

describe Kramdown::PlantUml::Logger do
  describe '#new' do
    subject { Kramdown::PlantUml::Logger }

    context 'with nil logger' do
      it { expect { subject.new(nil) }.to raise_error(ArgumentError, 'logger cannot be nil') }
    end

    context 'with logger not responding to #debug' do
      it { expect { subject.new({}) }.to raise_error(ArgumentError, 'logger must respond to #debug') }
    end
  end

  describe '#init' do
    subject { Kramdown::PlantUml::Logger.init }
    it { is_expected.to be_a Kramdown::PlantUml::Logger }
  end

  [:debug, :info , :warn, :error].each do |level|
    describe "\##{level}" do
      subject { Kramdown::PlantUml::Logger.init }
      it { is_expected.to respond_to(level) }
      it "receives \##{level}('test')" do
        expect_any_instance_of(Kramdown::PlantUml::ConsoleLogger).to receive(level).with('test')
        subject.public_send(level, 'test')
      end
    end
  end
end
