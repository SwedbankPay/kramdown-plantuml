# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/log_wrapper'
require 'kramdown-plantuml/console_logger'

Logger = ::Kramdown::PlantUml::Logger

describe Logger do
  describe '#new' do
    context 'with nil logger' do
      it { expect { Logger.new(nil) }.to raise_error(ArgumentError, 'logger cannot be nil') }
    end

    context 'with logger not responding to #debug' do
      it { expect { Logger.new({}) }.to raise_error(ArgumentError, 'logger must respond to #debug') }
    end

    [:debug, :info, :warn, :error].each do |level|
      context "with logger having level: #{level}" do
        subject do
          inner = double(debug: nil, info: nil, warn: nil, error: nil, level: level)
          Logger.new(inner)
        end
        its (:level) { should eq(level) }
      end
    end
  end

  describe '#init' do
    subject { Logger.init }
    it { is_expected.to be_a Logger }
  end

  [:debug, :info , :warn, :error].each do |level|
    describe "\##{level}" do
      subject { Logger.init }
      it { is_expected.to respond_to(level) }
      it "receives \##{level}('test')" do
        expect_any_instance_of(Kramdown::PlantUml::ConsoleLogger).to receive(level).with(' kramdown-plantuml: test')
        subject.public_send(level, 'test')
      end
    end
  end
end
