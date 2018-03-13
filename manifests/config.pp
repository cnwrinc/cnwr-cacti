# == Class cacti::config
#
# This class is called from cacti for service config.
#
class cacti::config inherits cacti{

  file { '/etc/cacti/db.php':
    ensure  => present,
    content => template('cacti/etc/cacti/db.erb'),
    mode    => '0640',
    owner   => 'cacti',
    group   => 'apache',
  }

  augeas { 'cacti_perms':
    incl    => '/etc/httpd/conf.d/cacti.conf',
    lens    => 'Httpd.lns',
    context => '/files/etc/httpd/conf.d/cacti.conf',
    changes => [
      'defnode req Directory[arg="/usr/share/cacti/"]/IfModule[arg="mod_authz_core.c"]/directive[.="Require"] "Require"',
      'set $req/arg[1] "all"',
      'set $req/arg[2] "granted"',

      'defnode nomodauthzcore Directory[arg="/usr/share/cacti/"]/IfModule[arg="!mod_authz_core.c"] ""',
      'set $nomodauthzcore/directive[.="Allow"]/arg[2] "all"',
    ],
    notify  => Service[$::cacti::managed_services],
  }

  cron::job { 'cacti':
    minute  => '*/5',
    command => '/usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1',
    user    => 'cacti',
  }


}
