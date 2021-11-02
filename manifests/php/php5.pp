# @summary Install php 5.x
#
# @param packages
#   List of packages to install for php
#
# @example
#   include profile_webserver_old::php::php5
class profile_webserver_old::php::php5 (
  Array[String] $packages,
) {

  ensure_packages( $packages, {'ensure' => 'installed', 'notify' => 'Service[httpd]'} )

}
