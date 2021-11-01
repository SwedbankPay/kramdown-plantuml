# frozen_string_literal: false

require 'rspec/its'
require 'kramdown-plantuml/options'

Options = Kramdown::PlantUml::Options

describe Options do
  let(:hash) { {} }
  subject { Options.new(hash) }

  context 'nil hash' do
    let(:hash) { nil }
    its(:theme_name) { is_expected.to be_nil }
    its(:theme_directory) { is_expected.to be_nil }
    its(:raise_errors?) { is_expected.to be true }
    its(:to_h) { is_expected.to eq({ }) }
  end

  context 'empty hash' do
    its(:theme_name) { is_expected.to be_nil }
    its(:theme_directory) { is_expected.to be_nil }
    its(:raise_errors?) { is_expected.to be true }
    its(:to_h) { is_expected.to eq({ }) }
  end

  context 'empty :plantuml' do
    let(:hash) { { plantuml: { } } }
    its(:to_h) { is_expected.to eq({ }) }
  end

  context 'empty :theme' do
    let(:hash) { { plantuml: { theme: {  } } } }
    its(:to_h) { is_expected.to eq({ theme: { } }) }
  end

  context 'with :theme :name' do
    let(:hash) { { plantuml: { theme: { name: 'custom' } } } }
    its(:to_h) { is_expected.to eq({ theme: { name: 'custom' } }) }
  end

  context 'invalid :raise_errors' do
    let(:hash) { { plantuml: { theme: { }, raise_errors: 'xyz' } } }
    its(:raise_errors?) { is_expected.to be true }
  end

  context 'with symbolic option keys' do
    let(:hash) { { plantuml: { theme: { name: 'custom', directory: 'path/to/themes' }, raise_errors: false } } }
    its(:theme_name) { is_expected.to eq('custom') }
    its(:theme_directory) { is_expected.to eq('path/to/themes') }
    its(:raise_errors?) { is_expected.to be false }
    its(:to_h) { is_expected.to eq({ theme: { name: 'custom', directory: 'path/to/themes'}, raise_errors: false }) }
  end

  context 'with mixed option keys' do
    let(:hash) { { plantuml: { theme: { 'name' => 'custom', 'directory' => 'path/to/themes' }, 'raise_errors' => false } } }
    its(:theme_name) { is_expected.to eq('custom') }
    its(:theme_directory) { is_expected.to eq('path/to/themes') }
    its(:raise_errors?) { is_expected.to be false }
    its(:to_h) { is_expected.to eq({ theme: { name: 'custom', directory: 'path/to/themes'}, raise_errors: false }) }
  end

  context 'with string option keys' do
    let(:hash) { { 'plantuml' => { 'theme' => { 'name' => 'custom', 'directory' => 'path/to/themes' }, 'raise_errors' => false } } }
    its(:theme_name) { is_expected.to eq('custom') }
    its(:theme_directory) { is_expected.to eq('path/to/themes') }
    its(:raise_errors?) { is_expected.to be false }
    its(:to_h) { is_expected.to eq({ theme: { name: 'custom', directory: 'path/to/themes' }, raise_errors: false })}
  end
end
