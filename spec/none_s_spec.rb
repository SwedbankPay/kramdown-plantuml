# frozen_string_literal: false

require 'kramdown-plantuml/none_s'

describe Object do
  describe '#none_s?' do
    subject { value.none_s? }

    context 'with invalid values' do
      [{}, [], nil, '', '     ', 'a', '0', '1', 'true', 'false', 'nil', '[]', '{}'].each do |v|
        context "'#{v}'" do
          let (:value) { v }
          it { is_expected.to be false }
        end
      end
    end

    context 'with valid values' do
      ['none', '   none    ', 'NONE', 'NoNe', :none].each do |v|
        context "'#{v}'" do
          let (:value) { v }
          it { is_expected.to be true }
        end
      end
    end
  end
end
