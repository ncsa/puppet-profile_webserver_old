# @summary Configure typical webserver
#
# @example
#   include profile_webserver_old
class profile_webserver_old {

  include profile_webserver_old::firewall
  include profile_webserver_old::packages
  include profile_webserver_old::php
  #include common::oom

  # config settings
  # https://jira.ncsa.illinois.edu/browse/HELPITS-2134
  file { '/etc/httpd/conf.d/000_ncsa_security.conf':
    ensure  => 'file',
    source  => [
      "puppet:///modules/${module_name}/etc/httpd/conf.d/000_ncsa_security.conf.${::hostname}",
      "puppet:///modules/${module_name}/etc/httpd/conf.d/000_ncsa_security.conf.${::domain}",
      "puppet:///modules/${module_name}/etc/httpd/conf.d/000_ncsa_security.conf.default",
    ],
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
  File_line {
    path    => '/etc/httpd/conf/httpd.conf',
    replace => true,
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
  file_line { 'httpd.conf ServerSignature Off':
    line  => 'ServerSignature Off',
    match => 'ServerSignature .*',
  }
  file_line { 'httpd.conf ServerTokens Prod':
    line  => 'ServerTokens Prod',
    match => 'ServerTokens .*',
  }

  ## REMOVE <VirtualHost> FILE FROM /etc/httpd/conf.d/ssl.conf
  exec { 'remove_virtualhost_from_ssl.conf':
    path    => ['/usr/bin', '/usr/sbin'],
    command => 'mv -f /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig && \
      grep -B9000 \'VirtualHost _default_\' /etc/httpd/conf.d/ssl.conf.orig | \
      grep -v \'VirtualHost _default_\' > /etc/httpd/conf.d/ssl.conf',
    onlyif  => 'grep -qi VirtualHost /etc/httpd/conf.d/ssl.conf',
    require => Package['httpd'],
    notify  => Service['httpd'],
  }

  ## INSTALL LATEST INTERMEDIATE CERT FROM INCOMMON  
  file { '/etc/pki/tls/certs/incommon_usertrust_intermediate.crt':
    ensure  => 'file',
    source  => "puppet:///modules/${module_name}/etc/pki/tls/certs/incommon_usertrust_intermediate.crt",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['mod_ssl'],
  }

  # web logs
  file { '/etc/logrotate.d/httpd':
    source => [
      "puppet:///modules/${module_name}/etc/logrotate.d/httpd.${::hostname}",
      "puppet:///modules/${module_name}/etc/logrotate.d/httpd.${::domain}",
      "puppet:///modules/${module_name}/etc/logrotate.d/httpd",
    ],
    mode   => '0644',
  }

}
