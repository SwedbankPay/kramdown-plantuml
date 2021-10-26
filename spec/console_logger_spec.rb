# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/log_wrapper'
require 'kramdown-plantuml/console_logger'

ConsoleLogger ||= ::Kramdown::PlantUml::ConsoleLogger

describe ConsoleLogger do
  describe '#new' do
    [:debug, :info, :warn, :error].each do |level|
      context "level: #{level}" do
        subject { ConsoleLogger.new(level) }
        it { is_expected.to respond_to(level) }

        describe "\##{level}" do
          it "receives \##{level}('test')" do
            expect_any_instance_of(ConsoleLogger).to receive(level).with('test')
            subject.public_send(level, 'test')
          end
        end
      end
    end
  end
end
