require 'spec_helper'

describe 'dell::firmware', :type => :class do
  context "osfamily = RedHat" do
    let :facts do
      {
        :osfamily        => 'RedHat',
      }
    end

    context "default usage (osfamily = RedHat)" do
      let(:title) { 'dell-firmware-basic' }

      it 'should compile' do
        should contain_package('dell_ft_install')
      end
    end
  end
end
