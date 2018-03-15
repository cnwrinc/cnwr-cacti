# == Class cacti::mysql
#
# This class is called from cacti for database config.
# git@github.com:puppetlabs/puppetlabs-mysql.git
class cacti::mysql(
  $database_root_pass = $::cacti::database_root_pass,
  $database_user      = $::cacti::database_user,
  $database_pass      = $::cacti::database_pass,
  $database_host      = $::cacti::database_host,
  $cacti_package      = $::cacti::cacti_package,
  $override_options   = {
    'mysqld' => {
      'max_heap_table_size'             => $::memory['system']['total_bytes'] * 0.10,
      'max_allowed_packet'              => '16M',
      'tmp_table_size'                  => '64M',
      'join_buffer_size'                => '64M',
      'innodb_file_per_table'           => 'ON',
      'innodb_buffer_pool_size'         => $::memory['system']['total_bytes'] * 0.25,
      'innodb_doublewrite'              => 'OFF',
      'innodb_additional_mem_pool_size' => '80M',
      'innodb_lock_wait_timeout'        => '50',
      'innodb_flush_log_at_trx_commit'  => '2',
      'character-set-server'            => 'utf8',
      'collation-server'                => 'utf8_general_ci',
    },
  },
) {

  class { '::mysql::server':
    root_password           => $database_root_pass,
    remove_default_accounts => true,
    override_options        => $override_options,
  }

  mysql::db { 'cacti':
    user     => $database_user,
    password => $database_pass,
    host     => $database_host,
    grant    => ['ALL'],
    sql      => '/usr/share/doc/cacti-*/cacti.sql',
    charset  => 'utf8',
    collate  => 'utf8_general_ci',
    require  => Package[$cacti_package],
  }

  mysql::db { 'mysql':
    user     => $database_user,
    password => $database_pass,
    host     => $database_host,
    grant    => ['ALL'],
    charset  => 'utf8',
    collate  => 'utf8_general_ci',
  }

}
