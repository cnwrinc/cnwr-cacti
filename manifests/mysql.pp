# == Class cacti::mysql
#
# This class is called from cacti for database config.
# git@github.com:puppetlabs/puppetlabs-mysql.git
class cacti::mysql(
  $override_options = {
    'mysqld' => {
      'max_heap_table_size'             => Integer($::memory['system']['total_bytes'] * 0.10),
      'max_allowed_packet'              => '16M',
      'tmp_table_size'                  => '64M',
      'join_buffer_size'                => '64M',
      'innodb_file_per_table'           => 'ON',
      'innodb_buffer_pool_size'         => Integer($::memory['system']['total_bytes'] * 0.25),
      'innodb_doublewrite'              => 'OFF',
      'innodb_additional_mem_pool_size' => '80M',
      'innodb_lock_wait_timeout'        => '50',
      'innodb_flush_log_at_trx_commit'  => '2',
      'character-set-server'            => 'utf8',
      'collation-server'                => 'utf8_general_ci',
    },
  },
) inherits ::cacti {

  class { '::mysql::server':
    root_password           => $::cacti::database_root_pass,
    remove_default_accounts => true,
    override_options        => $override_options,
  }

  mysql::db { 'cacti':
    user     => $::cacti::database_user,
    password => $::cacti::database_pass,
    host     => $::cacti::database_host,
    grant    => ['ALL'],
    sql      => glob('/usr/share/doc/cacti-*/cacti.sql'),
    charset  => 'utf8',
    collate  => 'utf8_general_ci',
    require  => Package[$::cacti::cacti_package],
  }

  mysql::db { 'mysql':
    user     => $::cacti::database_user,
    password => $::cacti::database_pass,
    host     => $::cacti::database_host,
    grant    => ['ALL'],
    charset  => 'utf8',
    collate  => 'utf8_general_ci',
  }

}
