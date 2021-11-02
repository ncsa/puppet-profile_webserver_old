# @summary Configure packages and httpd service
#
# @param absent
#   List of packages to remove
#
# @param installed
#   List of packages to install
#
# @example
#   include profile_webserver_old::packages
class profile_webserver_old::packages (
  Array[String] $absent,
  Array[String] $installed,
) {

  ensure_packages( $absent, {'ensure' => 'purged', 'notify' => 'Service[httpd]'} )
  ensure_packages( $installed, {'ensure' => 'present', 'notify' => 'Service[httpd]'} )

  file { '/etc/httpd/conf.d/mod_evasive.conf':
    ensure => 'absent',
#    ensure => 'file',
#    source => [
#      "puppet:///modules/${module_name}/etc/httpd/conf.d/mod_evasive.conf.${::hostname}",
#      "puppet:///modules/${module_name}/etc/httpd/conf.d/mod_evasive.conf.${::domain}",
#      "puppet:///modules/${module_name}/etc/httpd/conf.d/mod_evasive.conf.default",
#    ],
#    mode   => '0644',
#    owner  => 'root',
#    group  => 'root',
#    notify => Service['httpd'],
  }

  service { 'httpd':
    ensure => 'running',
    enable => 'true',
  }

}
