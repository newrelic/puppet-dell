# == Class: dell::openmanage
#
# This configures basic packages for Dell's OpenManage
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
#  class { 'dell::openmanage': }
#
class dell::openmanage (
  $idrac     = true,
  $storage   = true,
  $webserver = false,
) inherits dell::params {

  ########################################
  # Base packages and services
  ########################################
  $base_packages = [
    'srvadmin-omilcore',
    'srvadmin-deng',
    'srvadmin-omcommon',
  ]
  package { $base_packages:
    ensure  => 'present',
    require => Class['dell::repos'],
  }

  service { 'dataeng':
    ensure     => 'running',
    hasrestart => true,
    hasstatus  => true,
    require    => Package['srvadmin-deng'],
  }

  # OMSA 7.2 really needs IPMI to function
  case $::osfamily {
    'Debian' : {
      package { 'openipmi':
        ensure => installed,
        alias  => 'OpenIPMI',
      }
      $ipmiservice = 'openipmi'
    }
    'RedHat' : {
      package { 'OpenIPMI':
        ensure => installed,
      }
      $ipmiservice = 'ipmi'
    }
  }

  service { $ipmiservice:
    ensure => running,
    enable => true,
    notify => Service['dataeng'],
    require => Package['OpenIPMI'],
  }

  ########################################
  # iDRAC (default: true)
  ########################################
  $idrac_packages = [
    'srvadmin-idrac',
    'srvadmin-idrac7',
    'srvadmin-idracadm7',
  ]
  if $idrac {
    package { $idrac_packages:
      ensure  => 'present',
      require => Class['dell::repos'],
    }
  }

  ########################################
  # Storage (default: true)
  ########################################
  $storage_packages = [
    'srvadmin-storage',
    'srvadmin-storage-cli',
  ]
  if $storage {
    package { $storage_packages:
      ensure  => 'present',
      require => Class['dell::repos'],
    }
  }

  ########################################
  # Web interface (default: false)
  ########################################
  if $webserver {
    package { 'srvadmin-webserver':
      ensure  => 'present',
      require => Class['dell::repos'],
    }
  }
}

