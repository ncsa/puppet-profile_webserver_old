# @summary Install and configure OpenID Connect module for httpd
#
# @param packags
#   List of package resources for OpenID Connect
#
# @example
#   include profile_webserver_old::oidc
class profile_webserver_old::oidc (
  Hash $packages,
) {

  $ensure_packages_defaults = {
    'notify' => 'Service[httpd]',
  }

  ensure_resources('package', $packages, $ensure_packages_defaults )

}
