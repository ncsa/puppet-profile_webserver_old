# @summary Optional install and configure shibbolth
#
# @param packages
#   List of packages to install for shibboleth
#
# @example
#   include profile_webserver_old::shibboleth
class profile_webserver_old::shibboleth (
  Array[String] $packages,
) {

  # YUM REPO
  yumrepo { 'shibboleth':
    ensure     => present,
    descr      => 'Shibbolth',
    mirrorlist => "https://shibboleth.net/cgi-bin/mirrorlist.cgi/CentOS_${::facts['os']['release']['major']}",
    enabled    => 1,
    gpgkey     => "https://download.opensuse.org/repositories/security:/shibboleth/CentOS_${::facts['os']['release']['major']}/repodata/repomd.xml.key",
    gpgcheck   => 1,
    protect    => 0,
  }

  $ensure_packages_defaults = {
    'ensure'  => 'installed',
    'require' => 'Yumrepo[shibboleth]',
  }
  ensure_packages($packages, $ensure_packages_defaults )

  # CONFIGS
  file { '/etc/shibboleth':
    ensure  => directory,
    recurse => true,
    purge   => false,
    source  => "puppet:///modules/${module_name}/etc/shibboleth",
    require => [
      Package[$packages],
    ],
    notify  => Service['shibd'],
  }

  # NOTIFY IF HAVEN'T SET UNIQUE entityID
  exec { 'shib_entityID_not_set_correctly':
    path    => ['/usr/bin', '/usr/sbin'],
    command => 'logger -st shibboleth \'entityID is not set correctly in /etc/shibboleth/shibboleth2.xml\'',
    onlyif  => [
      'grep -i entityID /etc/shibboleth/shibboleth2.xml | grep -i host.name.illinois.edu  ||  \
       grep -i entityID /etc/shibboleth/shibboleth2.xml | grep -i sp.example.org',
    ],
    unless  => [
      'grep -i entityID /etc/shibboleth/shibboleth2.xml | grep -i `hostname`',
    ],
  }

  exec { 'shib_keygen':
    path    => ['/usr/bin', '/usr/sbin'],
    cwd     => '/etc/shibboleth',
    command => "/etc/shibboleth/keygen.sh –h ${::fqdn} –e https://${::fqdn}/shibboleth -f -y 10",
    creates => '/etc/shibboleth/sp-key.pem',
    notify  => Service['shibd'],
    require => [
      Package[$packages],
    ],
  }

  # SERVICE
  service { 'shibd':
    ensure  => 'running',
    enable  => true,
    require => [
      Package[$packages],
    ],
  }

}
