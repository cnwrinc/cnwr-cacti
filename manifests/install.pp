# == Class cacti::install
#
# This class is called from cacti for install.
#
class cacti::install (
  $cacti_package    = $::cacti::cacti_package,
  $configure_epel   = $::cacti::configure_epel,
  $configure_php    = $::cacti::configure_php,
  $php_timezone     = $::cacti::php_timezone,
  $managed_services = $::cacti::managed_services,
){

  package { $cacti_package:
    ensure  => present,
  }

  if $configure_epel {
    include ::epel
    Class['epel'] -> Package[$cacti_package]
  }

  if $configure_php {
    package { 'php':
      ensure => present,
      before => Package[$cacti_package],
    }

    class { '::php':
      notify   => Service[$managed_services],
      settings => {
        'Date/date.timezone' => $php_timezone,
      },
    }
  }

}
