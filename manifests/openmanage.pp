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

  case $::osfamily {
    'RedHat' : {
      case $operatingsystemrelease {
        /^[1-6]\./: {
          if $environment != 'vagrant' {
            service { 'dataeng':
              ensure     => 'running',
              hasrestart => true,
              hasstatus  => true,
              require    => [ Package['srvadmin-deng'] ],
            }
          }
        }
        default: {
          exec { "IGNORE_GENERATION":
            cwd     => "/var/tmp",
            command => "mkdir -p /opt/dell/srvadmin/lib64/openmanage && touch /opt/dell/srvadmin/lib64/openmanage/IGNORE_GENERATION",
            creates => "/opt/dell/srvadmin/lib64/openmanage/IGNORE_GENERATION",
            path    => ["/bin", "/usr/bin"]
          }
          if $environment != 'vagrant' {
            service { 'dataeng':
              ensure     => 'running',
              hasrestart => true,
              hasstatus  => true,
              require    => [ Package['srvadmin-deng'], Exec['IGNORE_GENERATION'] ],
            }
          }
        }
      }
    }
    default: {
      if $environment != 'vagrant' {
        service { 'dataeng':
          ensure     => 'running',
          hasrestart => true,
          hasstatus  => true,
          require    => Package['srvadmin-deng'],
        }
      }
    }
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

  # WSMAN is used for BIOS configuration
  case $::osfamily {
    'Debian' : {
      $wsman_packages = ['curl', 'libxml2-utils', 'coreutils', 'wsl']
      ensure_packages($wsman_packages)
    }
    'RedHat' : {
      $wsman_packages = ['wsmancli']
      ensure_packages($wsman_packages)
    }
  }

  # check_openmanage needs these packages
  case $::osfamily {
    'Debian' : {
      $checkom_packages = ['libnet-snmp-perl', 'libconfig-tiny-perl', 'libxslt1.1']
      ensure_packages($checkom_packages)
    }
    'RedHat' : {
      $checkom_packages = ['perl-Net-SNMP', 'perl-Config-Tiny', 'libxslt']
      ensure_packages($checkom_packages)
    }
  }

  file { '/usr/local/bin/check_openmanage':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dell/check_openmanage',
  }

  file { '/usr/share/man/man8/check_openmanage.8':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dell/check_openmanage.8',
  }

  file { '/usr/share/man/man5/check_openmanage.conf.5':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '644',
    source => 'puppet:///modules/dell/check_openmanage.conf.5',
  }

  file { '/etc/check_openmanage.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dell/check_openmanage.conf.erb'),
  }

  # This can be removed sometime after 20140310
  file { '/etc/cron.hourly/check_openmanage':
    ensure => 'absent',
    source => 'puppet:///modules/dell/check_openmanage.cron',
    mode   => '0755',
  }

  file { '/etc/cron.daily/check_openmanage':
    ensure => 'present',
    source => 'puppet:///modules/dell/check_openmanage.cron',
    mode   => '0755',
  }

  if $environment != 'vagrant' {
    service { $ipmiservice:
      ensure => running,
      enable => true,
      notify => Service['dataeng'],
      require => Package['OpenIPMI'],
    }
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
