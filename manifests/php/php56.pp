# @summary Install php 5.6
#
# @param packages
#   List of packages to install for php
#
# @example
#   include profile_webserver_old::php::php56
class profile_webserver_old::php::php56 (
  Array[String] $packages,
) {

  ## https://webtatic.com/packages/php56/

  # rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
  package { 'webtatic-release':
    ensure   => 'present',
    source   => "https://mirror.webtatic.com/yum/el${::facts['os']['release']['major']}/webtatic-release.rpm",
    provider => 'rpm'
  }

  exec { 'uninstall_other_php_pkgs':
    path    => ['/usr/bin', '/usr/sbin'],
    command => 'yum remove -y php php* php7* mod_php* && rm -rf /usr/lib64/php',
    onlyif  => 'rpm -qa | grep php | egrep \'\-5.4|php7\'',
  }

  $ensure_packages_defaults = {
    'ensure' => 'installed',
    'notify' => 'Service[httpd]',
    'require' => [
      'Package[webtatic-release]',
      'Exec[uninstall_other_php_pkgs]',
    ],
  }
  ensure_resources('package', $packages, $ensure_packages_defaults )
  #ensure_packages( $packages, {'ensure' => 'installed', 'notify' => 'Service[httpd]'} )

  ## ABOVE SHOULD REALLY ALSO REQUIRE FOLLOWING BUT NOT SURE HOW TO DO THAT
  #  require => [
  #    Package['webtatic-release'],
  #    Exec['uninstall_other_php_pkgs'],
  #  ],

}
