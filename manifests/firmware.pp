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

  package { 'dell_ft_install':
    ensure  => $ensure,
    require => Class['dell::repos'],
  }

}

