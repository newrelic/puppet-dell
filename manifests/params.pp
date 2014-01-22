# == Class: dell::params
#
# This contains the default parameters used by the Dell class
#
# === Variables
#
#
# === Examples
#
#  class { 'dell::params': }
#
class dell::params {

  case $::osfamily {
    'RedHat': {
      $repo_indep_mirrorlist    = "http://linux.dell.com/repo/hardware/latest/mirrors.cgi?osname=el${::lsbmajdistrelease}&basearch=\$basearch&native=1&dellsysidpluginver=\$dellsysidpluginver"
      $repo_indep_gpgkey        = 'http://linux.dell.com/repo/hardware/latest/RPM-GPG-KEY-dell'
      $repo_specific_mirrorlist = "http://linux.dell.com/repo/hardware/latest/mirrors.cgi?osname=el${::lsbmajdistrelease}&basearch=\$basearch&native=1&sys_ven_id=\$sys_ven_id&sys_dev_id=\$sys_dev_id&dellsysidpluginver=\$dellsysidpluginver"
      $repo_specific_gpgkey     = 'http://linux.dell.com/repo/hardware/latest/RPM-GPG-KEY-dell'
    }
    'Debian': {
    }
    default: {
      fail("Unsupported OS Family: ${::osfamily}")
    }
  }
}
