# Fact: racadm
#
# Purpose: Return the racadm information from Dell hardware
#
# Resolution:
#   On Linux, queries racadm getconfig -g for each group in the query hash
#
# Author: Mikael Fridh <mfridh@marinsoftware.com>
#
# TODO Instead of sweeping output once per key, sweep once and
#      lookup keys in hash (racadm output format seems more reliable than
#      dmidecode anyway. ( cfgKeyName=value )

module Facter::Drac

  def self.get_racadm_output(group)
    case Facter.value(:kernel)
    when 'Linux'
      return nil unless FileTest.exists?("/opt/dell/srvadmin/sbin/racadm")
      output=%x{/opt/dell/srvadmin/sbin/racadm getconfig -g #{group} 2>/dev/null}
    else
      output=nil
    end
    return output
  end

  def self.find_drac_info(group)
    group.each_pair do |key,v|
      output = self.get_racadm_output(key)
      return if output.nil?
      v.each do |v2|
        v2.each_pair do |value,facterkey|
          output.each_line do |line|
            if line =~ /#{value}=(.+)\n/
              result = $1.strip
              Facter.add(facterkey) do
                confine :kernel => [ :linux, :freebsd, :netbsd, :sunos, :"gnu/kfreebsd" ]
                setcode do
                  result
                end
              end
            end
          end
        end
      end
    end
  end

end

if Facter.value(:manufacturer) =~ /Dell/
  query = {
  'cfgLanNetworking' => [
    { 'cfgNicIpAddress'  => 'drac_ipaddress' },
    { 'cfgNicNetmask'    => 'drac_netmask' },
    { 'cfgNicGateway'    => 'drac_gateway' },
    { 'cfgNicUseDhcp'    => 'drac_dhcp' },
    { 'cfgNicMadAddress' => 'drac_macaddress' },
    { 'cfgNicVlanEnable' => 'drac_vlan' },
    { 'cfgNicVlanID'     => 'drac_vlanid' },
    { 'cfgDNSServersFromDHCP' => 'drac_dnsserversfromdhcp' },
    { 'cfgDNSServer1' => 'drac_dnsserver1' },
    { 'cfgDNSServer2' => 'drac_dnsserver2' },
    { 'cfgDNSRacName' => 'drac_name' },
    { 'cfgDNSDomainName' => 'drac_domain' },
    { 'cfgDNSDomainNameFromDHCP' => 'drac_dnsdomainnamefromdhcp' },
    { 'cfgDNSRegisterRac' => 'drac_dns_register' },
  ],
  'cfgIpmiSol' => [
    { 'cfgIpmiSolEnable' => 'drac_ipmisolenable' },
    { 'cfgIpmiLanEnable' => 'drac_ipmilanenable' },
    { 'cfgIpmiSolBaudRate' => 'drac_ipmisolbaudrate' },
  ],
  'cfgIpmiLan' => [
    { 'cfgIpmiLanEnable' => 'drac_ipmilanenable' },
  ],
  }

  Facter::Drac.find_drac_info(query)
end

if Facter.value(:drac_ipaddress)
  Facter.add('drac_url') do
    setcode do
      ip = Facter.value(:drac_ipaddress)
      "https://#{ip}/"
    end
  end
end