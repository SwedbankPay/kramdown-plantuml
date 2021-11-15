# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/style_builder'

StyleBuilder ||= Kramdown::PlantUml::StyleBuilder

describe StyleBuilder do
  subject { StyleBuilder.new }

  context '[nil]' do
    before(:each) { subject[nil] = '' }
    its(:to_s) { is_expected.to eq '' }
  end

  context 'nil value' do
    before(:each) { %i[width height style].each { |key| subject[key] = nil }}
    its(:to_s) { is_expected.to eq '' }
  end

  context '[:width]' do
    before(:each) { subject[:width] = '200px' }
    its(:to_s) { is_expected.to eq 'width:200px' }
  end

  context '[:height]' do
    before(:each) { subject[:height] = '200px' }
    its(:to_s) { is_expected.to eq 'height:200px' }
  end
  context '[:width, :height, :style]' do
    before(:each) do
      subject[:height] = '200px'
      subject[:width] = '1337px'
      subject[:style] = 'border: 1px solid red; background-color: #ffffff;'
    end

    its(:to_s) { is_expected.to eq 'background-color:#ffffff;border:1px solid red;height:200px;width:1337px' }
  end
end
