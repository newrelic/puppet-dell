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

      #Some Dell stuff installs this, remove it and use ours
      file { '/etc/yum.repos.d/dell-omsa-repository.repo'
         ensure => 'absent',
      }

      yumrepo { 'dell-omsa-indep':
        descr          => 'Dell OMSA repository - Hardware independent',
        enabled        => 1,
        mirrorlist     => $dell::params::repo_indep_mirrorlist,
        gpgcheck       => 1,
        gpgkey         => $dell::params::repo_indep_gpgkey,
        failovermethod => 'priority',
        require        => File['/etc/yum.repos.d/dell-omsa-repository.repo'],
      } -> package { 'yum-dellsysid':  # I dislike this syntax, but require would not work for some reason...
        ensure  => 'present',
      }

      yumrepo { 'dell-omsa-specific':
        descr          => 'Dell OMSA repository - Hardware specific',
        enabled        => 1,
        mirrorlist     => $dell::params::repo_specific_mirrorlist,
        gpgcheck       => 1,
        gpgkey         => $dell::params::repo_specific_gpgkey,
        failovermethod => 'priority',
        require        => File['/etc/yum.repos.d/dell-omsa-repository.repo'],
      }


      ########################################
      # GPG-KEY Management
      ########################################
      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-dell':
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/dell/RPM-GPG-KEY-dell',
      }
      exec { 'dell-RPM-GPG-KEY-dell':
        command     => '/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-dell',
        subscribe   => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-dell'],
        refreshonly => true,
      }

      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-libsmbios':
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/dell/RPM-GPG-KEY-libsmbios',
      }
      exec { 'dell-RPM-GPG-KEY-libsmbios':
        command     => '/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-libsmbios',
        subscribe   => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-libsmbios'],
        refreshonly => true,
      }


      ########################################
      # Packages
      ########################################

      # This would add duplicate repos, and we want to manage them explicitly
      package { 'dell-omsa-repository':
        ensure => 'absent',
      }
    }
  }
}

