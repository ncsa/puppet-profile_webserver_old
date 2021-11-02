# @summary Install php 7.x
#
# @param packages
#   List of packages to install for php
#
# @example
#   include profile_webserver_old::php::php7
class profile_webserver_old::php::php7 (
  Array[String] $packages,
) {

  if ( $facts['os']['family'] =~ /^RedHat/ and $facts['os']['release']['major'] <= '7' )
  {
    ## https://webtatic.com/packages/php72/
    ## CONSIDER SWITCHING TO https://ius.io/GettingStarted/

    package { 'webtatic-release':
      ensure   => 'present',
      source   => "https://mirror.webtatic.com/yum/el${::facts['os']['release']['major']}/webtatic-release.rpm",
      provider => 'rpm'
    }

    exec { 'uninstall_default_php_pkgs':
      path    => ['/usr/bin', '/usr/sbin'],
      command => 'yum remove -y php php* php71w* mod_php* && rm -rf /usr/lib64/php',
      onlyif  => 'rpm -qa | grep php | egrep \'\-5.|php71w\'',
    }

    ensure_packages( $packages, {'ensure' => 'installed', 'notify' => 'Service[httpd]'} )

  }
  elsif ( $facts['os']['family'] =~ /^RedHat/ and $facts['os']['release']['major'] >= '8' )
  {

    # USE 7.4 VERSION OF YUM/DNF PHP MODULE
    $dnf_php_command = 'dnf -y module reset php && dnf -y module enable php:7.4'
    exec { 'ensure_dnf_php_module_7.4':
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      unless  => 'dnf module list php | grep 7.4 | egrep -i \'7.4 \[[e|d]\]\'',
      command => $dnf_php_command,
    }

    ensure_packages( $packages, {'ensure' => 'installed', 'notify' => 'Service[php-fpm]'} )

    service { 'php-fpm':
      ensure  => 'running',
      enable  => true,
      require => [
        Package['php-fpm'],
      ],
    }

  }

}
