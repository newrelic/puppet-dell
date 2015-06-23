# == Class: dell::firmware
#
# Manage Dell system firmware packages
#
# === Parameters
#
# [*sample_parameter*]
#
# === Variables
#
# [*sample_variable*]
#
# === Examples
#
#  class { 'dell::firmware': }
#
class dell::firmware(
  $ensure = 'present',
) inherits dell::params {

  case $::osfamily {
    'Debian' : {
      package { 'firmware-addon-dell':
        ensure  => $ensure,
        require => Class['dell::repos'],
      }
      package { 'firmware-tools':
        ensure  => $ensure,
        require => Class['dell::repos'],
      }
    }
    'RedHat' : {
      case $operatingsystemrelease {
        /^[1-6]\./: {
          package { 'dell_ft_install':
            ensure  => $ensure,
            require => Class['dell::repos'],
          }
        }
      }
    }
  }
}
