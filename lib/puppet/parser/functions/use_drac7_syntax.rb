module Puppet::Parser::Functions
  newfunction(:use_drac7_syntax, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall

    idrac_firmware_version = lookupvar('idrac_firmware_version')
    idrac_major_version    = lookupvar('idrac_major_version')

    if [idrac_firmware_version, idrac_major_version].include?(:undefined)
      function_warning(["Called use_drac7_syntax(), but no idrac facts were found."])
    elsif idrac_major_version.to_i >= 7 and function_versioncmp([idrac_firmware_version, '1.30.0']) >= 0
      true
    elsif idrac_major_version.to_i < 7 or function_versioncmp([idrac_firmware_version, '1.30.0']) < 0
      false
    else
      function_warning(["Failed to determine idrac version successfully. idrac_major_version was #{idrac_major_version}, idrac_firmware_version was #{idrac_firmware_version}"])
    end
  end
end
