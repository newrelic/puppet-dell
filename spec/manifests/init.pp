# == Class: dell
#
# This is a metaclass to pull in all of the Dell classes
#
# === Parameters
#
# None
#
# === Variables
#
# [*manufacturer*] - We verify that the manufacturer is Dell...
#
# === Examples
#
#  class { 'dell': }
#
class dell {
  # Make sure this is a Dell system or bad things could happen
  if $::manufacturer =~ /Dell/ {
    class { 'dell::repos': }
    class { 'dell::openmanage': }
    class { 'dell::firmware': }
  }
}

