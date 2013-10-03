require 'spec_helper'

describe 'dell::openmanage', :type => :class do
  context "osfamily = RedHat" do
    let :facts do
      {
        :osfamily        => 'RedHat',
      }
    end

    context "default usage (osfamily = RedHat)" do
      let(:title) { 'dell-openmanage-default' }

      it 'should compile' do
        # Base
        should contain_package('srvadmin-omilcore')
        should contain_package('srvadmin-deng')
        should contain_service('dataeng')

        # iDRAC
        should contain_package('srvadmin-idrac')

        # Storage
        should contain_package('srvadmin-storage')

        # Webserver
        #should not contain_package('srvadmin-webserver')
      end
    end

    context "with webserver usage (osfamily = RedHat)" do
      let(:title) { 'dell-openmanage-webserver' }

      let (:params) {
        {
          'webserver' => 'true',
        }
      }

      it 'should compile' do
        # Base
        should contain_package('srvadmin-omilcore')
        should contain_package('srvadmin-deng')
        should contain_service('dataeng')

        # iDRAC
        should contain_package('srvadmin-idrac')

        # Storage
        should contain_package('srvadmin-storage')

        # Webserver
        should contain_package('srvadmin-webserver')
      end
    end
  end
end
