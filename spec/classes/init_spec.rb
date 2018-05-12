require 'spec_helper'
describe 'lsyncd_csync2' do
  context 'with default values for all parameters' do
    it { should contain_class('lsyncd_csync2') }
  end
end
