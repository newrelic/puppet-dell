# == Class: dell::repo
#
# This configures the dell package repositories
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
#  class { 'dell::repos': }
#
class dell::repos() inherits dell::params {

  case $::osfamily {
    'Debian' : {

      # Dell APT Repos
      apt::key { 'dell-community':
        key        => '34D8786F',
        key_server => 'pool.sks-keyservers.net',
      }

      apt::source { 'dell-community':
        location          => 'http://linux.dell.com/repo/community/ubuntu',
        release           => '',
        repos             => 'precise openmanage',
        include_src       => false,
      }

    }
    'RedHat' : {

      ########################################
      # Create the two repos
      ########################################

      # Ensure that the old package isn't present.
      package { 'dell-omsa-repository':
        ensure => 'absent',
      }

	  yumrepo { 'dell-dsu-os_independent':
		descr          => 'Dell System Update Repository - OS Independent',
		baseurl        => 'http://linux.dell.com/repo/hardware/latest/os_independent/',
		gpgkey         => 'http://linux.dell.com/repo/hardware/latest/public.key',
		gpgcheck       => 1,
		enabled        => 1,
		failovermethod => 'priority',
	  }

	  yumrepo { 'dell-dsu-os_dependent':
		descr          => 'Dell System Update Repository - OS Dependent',
		mirrorlist     => 'http://linux.dell.com/repo/hardware/latest/mirrors.cgi?osname=el${::lsbmajdistrelease}&basearch=\$basearch&native=1',
		gpgkey         => 'http://linux.dell.com/repo/hardware/latest/public.key',
		gpgcheck       => 1,
		enabled        => 1,
		failovermethod => 'priority',
	  }

	  # TODO: Do we need to manage the RPM key, or does yumrepo do it?

      ########################################
      # GPG-KEY Management
      ########################################

      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-dsu':
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/dell/RPM-GPG-KEY-dsu',
      }

      exec { 'dell-RPM-GPG-KEY-dsu':
        command     => '/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-dsu',
        subscribe   => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-dsu'],
        refreshonly => true,
      }

	}
  }
}

