# frozen_string_literal: true

require 'rspec/its'
require 'kramdown-plantuml/which'

describe Which do
  describe '#which' do
    subject { Which.which(command) }

    context 'existing command' do
      let(:command) { 'ls' }
      it { is_expected.to match(/\/bin\/ls/) }
    end

    context 'non-existing command' do
      let(:command) { 'not_a_command' }
      it { is_expected.to be_nil }
    end
  end
end
