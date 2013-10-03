Puppet::Type.type(:drac_setting).provide(:idrac7) do
  # must support racadm get. using defaultfor instead of confine will allow
  # servers that do support the new syntax but have old firmware to fall back to
  # the idrac6 provider
  defaultfor :idrac_major_version => 7

  # must have idrac firmware >= 1.3
  confine :true => File.exist?('/opt/dell/srvadmin/sbin/racadm') &&
                   `/opt/dell/srvadmin/sbin/racadm getsysinfo` =~ /Firmware Version\s+= 1\.[3-9]/

  commands :racadm => '/opt/dell/srvadmin/sbin/racadm'

  def object_value
    fqdd = racadm_fqdd(resource[:group], resource[:object_name], resource[:object_index])
    result = racadm('get', fqdd).strip

    # racadm has two somewhat unpredictable response formats
    if result =~ /^\[Key=/
      # for non-indexed values, racadm get returns values like:
      # [Key=iDRAC.Embedded.1#SNMP.1]
      # TrapFormat=SNMPv2
      # We just want the value, so extract that with regex
      result[/\[.*\]\n\w+=(.*)/, 1]
    else
      # for indexed values like iDRAC.SNMP.Alert.1.DestAddr, it just returns
      # the value you wanted.
      zombie_check(result)
    end
  end

  def object_value=(value)
    fqdd = racadm_fqdd(resource[:group], resource[:object_name], resource[:object_index])
    zombie_check(racadm('set', fqdd, value).strip)
  end

  def racadm_fqdd(drac_group, drac_object, index=nil)
    if index.nil?
      "#{drac_group}.#{drac_object}"
    else
      "#{drac_group}.#{index}.#{drac_object}"
    end
  end

  def zombie_check(racadm_output)
    if racadm_output =~ /One Instance of Local RACADM is already executing/
      raise Puppet::Error, "Failed check/set, an instance of racadm is already running"
    else
      racadm_output
    end
  end

end
