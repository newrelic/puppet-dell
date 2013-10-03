#!/usr/bin/ruby
# Export the idrac version
#
require 'facter'

idrac_major_version = false

if File.exists?('/opt/dell/srvadmin/sbin/racadm')
  case `/opt/dell/srvadmin/sbin/racadm help`
  when /getconfig \s+-- display RAC/
    idrac_major_version = 6
  when /getconfig \s+-- Deprecated: display RAC/
    idrac_major_version = 7
  end
end

if idrac_major_version
  Facter.add("idrac_major_version") do
    setcode do
      idrac_major_version
    end
  end
end
