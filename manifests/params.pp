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
    }
    'Debian': {
    }
    default: {
      fail("Unsupported OS Family: ${::osfamily}")
    }
  }
}
