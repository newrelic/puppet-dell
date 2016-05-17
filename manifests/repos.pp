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
      # Repo Cleanup
      ########################################

      # Provide a way to expire the yum cache after modifying
      # repositories.
      #
      exec { 'yum-clean-expire-cache':
        user => 'root',
        path => '/usr/bin',
        command => 'yum clean expire-cache',
        refreshonly => true,
      }

      # Avoid dependency problems by ensuring that previous repo
      # definitions from this manifest aren't present.
      #
      package { 'dell-omsa-repository':
        ensure => 'absent',
        require => Exec[ 'yum-clean-expire-cache' ],
      }

      $dell_ft_repo_files = [
        '/etc/yum.repos.d/dell-omsa-indep.repo',
        '/etc/yum.repos.d/dell-omsa-specific.repo'
      ]
      file { $dell_ft_repo_files:
        ensure => 'absent',
        require => Exec[ 'yum-clean-expire-cache' ],
      }

      ########################################
      # Create the DSU Repositories
      ########################################

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
        mirrorlist     => 'http://linux.dell.com/repo/hardware/latest/mirrors.cgi?osname=el$releasever&basearch=$basearch&native=1',
        gpgkey         => 'http://linux.dell.com/repo/hardware/latest/public.key',
        gpgcheck       => 1,
        enabled        => 1,
        failovermethod => 'priority',
      }

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

