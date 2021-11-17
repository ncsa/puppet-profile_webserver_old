# @summary Configure firewall for webserver
#
# @param campus_subnets
#   List of campus networks used to limit access from
#
# @param limit_to_campus
#   Limit web access to campus networks
#
# @param limit_to_ncsa
#   Limit web access to NCSA networks
#
# @param ncsa_subnets
#   List of NCSA networks used to limit access from
#
# @example
#   include profile_webserver_old::firewall
class profile_webserver_old::firewall (
  Array[String] $campus_subnets,
  Boolean       $limit_to_campus,
  Boolean       $limit_to_ncsa,
  Array[String] $ncsa_subnets,
) {

  if $facts['hostname'] =~ /-test/
    or $facts['hostname'] =~ /-dev/
    or $limit_to_ncsa
  {
    ## LIMIT ACCESS TO ONLY FROM NCSA AND SSLLABS TESTING SITE
    each($ncsa_subnets) | $index, $value | {
      firewall { "0080 allow http connections from NCSA ${value}":
        proto  => 'tcp',
        dport  => '80',
        source => $value,
        action => 'accept',
      }
      firewall { "0443 allow https connections from NCSA ${value}":
        proto  => 'tcp',
        dport  => '443',
        source => $value,
        action => 'accept',
      }
    }

    firewall { '0080 allow http connections from SSLlabs':
      proto  => 'tcp',
      dport  => '80',
      source => '64.41.200.100/28',
      action => 'accept',
    }
    firewall { '0443 allow https connections from SSLlabs':
      proto  => 'tcp',
      dport  => '443',
      source => '64.41.200.100/28',
      action => 'accept',
    }
  }
  elsif $facts['hostname'] =~ /web1$/
    or $limit_to_campus
  {
    $campus_subnets.each | $location, $source_cidr |
    {
      firewall { "0080 allow http connections from ${source_cidr} on campus":
        dport  => '80',
        proto  => tcp,
        source => $source_cidr,
        action => accept,
      }
      firewall { "0443 allow https connections from ${source_cidr} on campus":
        dport  => '443',
        proto  => tcp,
        source => $source_cidr,
        action => accept,
      }
    }
    firewall { '0080 allow http connections from SSLlabs':
      proto  => 'tcp',
      dport  => '80',
      source => '64.41.200.100/28',
      action => 'accept',
    }
    firewall { '0443 allow https connections from SSLlabs':
      proto  => 'tcp',
      dport  => '443',
      source => '64.41.200.100/28',
      action => 'accept',
    }
  }
  else
  {
    firewall { '0080 allow http connections from anywhere':
      proto  => 'tcp',
      dport  => '80',
      action => 'accept',
    }
    firewall { '0443 allow https connections from anywhere':
      proto  => 'tcp',
      dport  => '443',
      action => 'accept',
    }
  }

}
