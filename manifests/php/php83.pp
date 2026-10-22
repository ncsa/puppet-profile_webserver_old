# @summary Install php 8.3
#
# @param packages
#   List of packages to install for php
#
# @example
#   include profile_webserver_old::php::php83
class profile_webserver_old::php::php83 (
  Array[String] $packages,
) {

  if ( $facts['os']['family'] =~ /^RedHat/ and $facts['os']['release']['major'] >= '8' )
  {

    # USE 8.3 VERSION OF YUM/DNF PHP MODULE
    $dnf_php_command = 'dnf -y module reset php && dnf -y module enable php:8.3'
    exec { 'ensure_dnf_php_module_8.3':
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      unless  => 'dnf module list php | grep 8.3 | egrep -i \'8.3 \[[e|d]\]\'',
      command => $dnf_php_command,
    }

    ensure_packages( $packages, {'ensure' => 'installed', 'notify' => 'Service[php-fpm]', 'require' => 'Exec[ensure_dnf_php_module_8.3]'} )

    service { 'php-fpm':
      ensure  => 'running',
      enable  => true,
      require => [
        Package['php-fpm'],
      ],
    }

  }
  else
  {
    fail("${module_name}: php 8.3 requires the php:8.3 dnf module stream (RedHat family 8 or newer)")
  }

}
