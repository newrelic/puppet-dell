#!/usr/bin/ruby
# Export the idrac firmware version
#
require 'facter'

idrac_firmware_version = false

#if File.exists?('/opt/dell/srvadmin/sbin/racadm')
#  sysinfo = `/opt/dell/srvadmin/sbin/racadm getsysinfo`
#  sysinfo =~ /Firmware Version\s+= (.*)/
#  idrac_firmware_version = $1
#end

if idrac_firmware_version
  Facter.add("idrac_firmware_version") do
    setcode do
      idrac_firmware_version
    end
  end
end
