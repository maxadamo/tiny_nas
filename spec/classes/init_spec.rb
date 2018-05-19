require 'spec_helper'
describe 'tiny_nas' do
  context 'with default values for all parameters' do
    it { is_expected.to contain_class('tiny_nas') }
  end
end
