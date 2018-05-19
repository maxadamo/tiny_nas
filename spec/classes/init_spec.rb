require 'spec_helper'
describe 'tiny_nas' do
  context 'with default values for all parameters' do
    it { should contain_class('tiny_nas') }
  end
end
