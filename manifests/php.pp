# @summary Install and configure PHP
#
# @param ini_file
#   Path of default php ini file
#
# @param ini_settings
#   php.ini settings
#
# @param prepend_file
#   Path of default php prepend file
#
# @param service
#   Name of service to restart for php configs to take effect
#
# @param version
#   version of PHP to install
#
# @example
#   include profile_webserver_old::php
class profile_webserver_old::php (
  String $ini_file,
  Hash   $ini_settings,
  String $prepend_file,
  String $service,
  String $version,
) {

  case $version {
    '7':      { include profile_webserver_old::php::php7 }
    '5.6':    { include profile_webserver_old::php::php56 }
    default:  { include profile_webserver_old::php::php5 }
  }

  file { $ini_file:
    ensure => 'present',
    mode   => '0644',
  }
  if ($ini_settings)
  {
    $ini_settings.each | $k, $v | {
      file_line { "${ini_file} ${k} = ${v}":
        path    => $ini_file,
        replace => true,
        line    => "${k} = ${v}",
        match   => "${k}.*",
        require => [
          File[$ini_file],
        ],
        notify  => [
          Service[$service],
        ],
      }
    }
  }

  file_line { '/etc/php.ini remove expose_php':
    path    => '/etc/php.ini',
    replace => true,
    line    => 'expose_php = Off',
    match   => '^expose_php.*',
    notify  => [
      Service[$service],
    ],
  }
  file_line { "${ini_file} disable expose_php":
    path    => $ini_file,
    replace => true,
    line    => 'expose_php = Off',
    match   => '^expose_php.*',
    require => File[$ini_file],
    notify  => [
      Service[$service],
    ],
  }

  file { $prepend_file:
    ensure => 'file',
    mode   => '0644',
    source => [
      "puppet:///modules/${module_name}/usr/share/php/prepend.php.${::hostname}",
      "puppet:///modules/${module_name}/usr/share/php/prepend.php.${::domain}",
      "puppet:///modules/${module_name}/usr/share/php/prepend.php.default",
    ],
    owner  => 'root',
    group  => 'apache',
    notify => [
      Service[$service],
    ],
  }

}
