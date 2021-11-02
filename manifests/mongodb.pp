# @summary Optional install and congifure mongodb
#
# @param directories
#   List of directories needed for mongodb
#
# @param packages
#   List of packages to install for mongodb
#
# @example
#   include profile_webserver_old::mongodb
class profile_webserver_old::mongodb (
  Array[String] $directories,
  Array[String] $packages,
) {

  ensure_packages( $packages, {'ensure' => 'present'} )

  file { $directories:
    ensure => 'directory',
    owner  => 'mongod',
    mode   => '0750',
  }

  service { 'mongod':
    ensure => 'running',
    enable => true,
  }

  exec {'install_php_mongodb_pecl':
    path    => '/opt/rh/rh-php72/root/bin/:/opt/rh/rh-php71/root/bin/:/opt/rh/rh-php70/root/bin/:/opt/rh/rh-php56/root/bin/:/usr/bin/',
    unless  => 'pecl list mongodb',
    command => 'pecl install mongodb',
    notify  => Service['httpd'],
    require => [
      Package['mongodb-server'],
    ],
  }

  file { '/etc/php.d/mongodb.ini':
    ensure => 'present',
    source => "puppet:///modules/${module_name}/etc/php.d/mongodb.ini",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['httpd'],
  }

}
