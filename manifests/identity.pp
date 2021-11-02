# @summary Install and configure extra packages needed by NCSA Identity website
#
# @param packages
#   List of extra packages needed for identity website
#
# @example
#   include profile_webserver_old::identity
class profile_webserver_old::identity (
  Array[String] $packages,
) {

  ensure_packages( $packages, {'ensure' => 'present'} )

  exec { 'pecl-install-gnupg':
    path    => ['/usr/bin', '/usr/sbin'],
    command => 'pecl install gnupg',
    unless  => 'pecl list | grep -i gnupg',
    notify  => Service['httpd'],
    require => [
      Package[$packages],
    ],
  }

  file { '/etc/php.d/gnupg.ini':
    ensure  => present,
    content => 'extension = gnupg.so',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Service['httpd'],
    require => Exec['pecl-install-gnupg'],
  }

}
