require 'spec_helper'

describe 'dell::repos', :type => :class do
  context "osfamily = RedHat" do
    let :facts do
      {
        :osfamily        => 'RedHat',
      }
    end

    context "default usage (osfamily = RedHat)" do
      let(:title) { 'dell-repos-basic' }

      it 'should compile' do
        should contain_yumrepo('dell-dsu-os_independent')
        should contain_yumrepo('dell-dsu-os_dependent')
        should contain_package('yum-dellsysid')
        should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-dsu')
        should contain_exec('dell-RPM-GPG-KEY-dsu')
      end
    end
  end
end
