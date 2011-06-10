use strict;
use Test::More;
use lib qw(t/lib);
use dbixcsl_common_tests;

my $dsn         = $ENV{DBICTEST_MYSQL_DSN} || '';
my $user        = $ENV{DBICTEST_MYSQL_USER} || '';
my $password    = $ENV{DBICTEST_MYSQL_PASS} || '';
my $test_innodb = $ENV{DBICTEST_MYSQL_INNODB} || 0;

my $skip_rels_msg = 'You need to set the DBICTEST_MYSQL_INNODB environment variable to test relationships.';

my $tester = dbixcsl_common_tests->new(
    vendor           => 'Mysql',
    auto_inc_pk      => 'INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT',
    innodb           => $test_innodb ? q{Engine=InnoDB} : 0,
    dsn              => $dsn,
    user             => $user,
    password         => $password,
    connect_info_opts=> { on_connect_call => 'set_strict_mode' },
    loader_options   => { preserve_case => 1 },
    skip_rels        => $test_innodb ? 0 : $skip_rels_msg,
    quote_char       => '`',
    no_inline_rels   => 1,
    no_implicit_rels => 1,
    data_types  => {
        # http://dev.mysql.com/doc/refman/5.5/en/data-type-overview.html
        # Numeric Types
        'bit'         => { data_type => 'bit', size => 1 },
        'bit(11)'     => { data_type => 'bit', size => 11 },

        'bool'        => { data_type => 'tinyint' },
        'boolean'     => { data_type => 'tinyint' },
        'tinyint'     => { data_type => 'tinyint' },
        'tinyint unsigned'
                      => { data_type => 'tinyint',   extra => { unsigned => 1 } },
        'smallint'    => { data_type => 'smallint' },
        'smallint unsigned'
                      => { data_type => 'smallint',  extra => { unsigned => 1 } },
        'mediumint'   => { data_type => 'mediumint' },
        'mediumint unsigned'
                      => { data_type => 'mediumint', extra => { unsigned => 1 } },
        'int'         => { data_type => 'integer' },
        'int unsigned'
                      => { data_type => 'integer',   extra => { unsigned => 1 } },
        'integer'     => { data_type => 'integer' },
        'integer unsigned'
                      => { data_type => 'integer',   extra => { unsigned => 1 } },
        'integer not null'
                      => { data_type => 'integer' },
        'bigint'      => { data_type => 'bigint' },
        'bigint unsigned'
                      => { data_type => 'bigint',    extra => { unsigned => 1 } },

        'serial'      => { data_type => 'bigint', is_auto_increment => 1, extra => { unsigned => 1 } },

        'float'       => { data_type => 'float' },
        'float unsigned'
                      => { data_type => 'float',     extra => { unsigned => 1 } },
        'double'      => { data_type => 'double precision' },
        'double unsigned'
                      => { data_type => 'double precision', extra => { unsigned => 1 } },
        'double precision' =>
                         { data_type => 'double precision' },
        'double precision unsigned'
                      => { data_type => 'double precision', extra => { unsigned => 1 } },

        # we skip 'real' because its alias depends on the 'REAL AS FLOAT' setting

        'float(2)'    => { data_type => 'float' },
        'float(24)'   => { data_type => 'float' },
        'float(25)'   => { data_type => 'double precision' },

        'float(3,3)'  => { data_type => 'float', size => [3,3] },
        'double(3,3)' => { data_type => 'double precision', size => [3,3] },
        'double precision(3,3)'
                      => { data_type => 'double precision', size => [3,3] },

        'decimal'     => { data_type => 'decimal' },
        'decimal unsigned'
                      => { data_type => 'decimal', extra => { unsigned => 1 } },
        'dec'         => { data_type => 'decimal' },
        'numeric'     => { data_type => 'decimal' },
        'fixed'       => { data_type => 'decimal' },

        'decimal(3)'   => { data_type => 'decimal', size => [3,0] },

        'decimal(3,3)' => { data_type => 'decimal', size => [3,3] },
        'dec(3,3)'     => { data_type => 'decimal', size => [3,3] },
        'numeric(3,3)' => { data_type => 'decimal', size => [3,3] },
        'fixed(3,3)'   => { data_type => 'decimal', size => [3,3] },

        # Date and Time Types
        'date'        => { data_type => 'date', datetime_undef_if_invalid => 1 },
        'datetime'    => { data_type => 'datetime', datetime_undef_if_invalid => 1 },
        'timestamp default current_timestamp'
                      => { data_type => 'timestamp', default_value => \'current_timestamp', datetime_undef_if_invalid => 1 },
        'time'        => { data_type => 'time' },
        'year'        => { data_type => 'year' },
        'year(4)'     => { data_type => 'year' },
        'year(2)'     => { data_type => 'year', size => 2 },

        # String Types
        'char'         => { data_type => 'char',      size => 1  },
        'char(11)'     => { data_type => 'char',      size => 11 },
        'varchar(20)'  => { data_type => 'varchar',   size => 20 },
        'binary'       => { data_type => 'binary',    size => 1  },
        'binary(11)'   => { data_type => 'binary',    size => 11 },
        'varbinary(20)'=> { data_type => 'varbinary', size => 20 },

        'tinyblob'    => { data_type => 'tinyblob' },
        'tinytext'    => { data_type => 'tinytext' },
        'blob'        => { data_type => 'blob' },

        # text(M) types will map to the appropriate type, length is not stored
        'text'        => { data_type => 'text' },

        'mediumblob'  => { data_type => 'mediumblob' },
        'mediumtext'  => { data_type => 'mediumtext' },
        'longblob'    => { data_type => 'longblob' },
        'longtext'    => { data_type => 'longtext' },

        "enum('foo','bar','baz')"
                      => { data_type => 'enum', extra => { list => [qw/foo bar baz/] } },
        "set('foo','bar','baz')"
                      => { data_type => 'set',  extra => { list => [qw/foo bar baz/] } },

        # RT#68717
        "enum('11,10 (<500)/0 DUN','4,90 (<120)/0 EUR') NOT NULL default '11,10 (<500)/0 DUN'"
                      => { data_type => 'enum', extra => { list => ['11,10 (<500)/0 DUN', '4,90 (<120)/0 EUR'] }, default_value => '11,10 (<500)/0 DUN' },
        "set('11_10 (<500)/0 DUN','4_90 (<120)/0 EUR') NOT NULL default '11_10 (<500)/0 DUN'"
                      => { data_type => 'set', extra => { list => ['11_10 (<500)/0 DUN', '4_90 (<120)/0 EUR'] }, default_value => '11_10 (<500)/0 DUN' },
        "enum('19,90 (<500)/0 EUR','4,90 (<120)/0 EUR','7,90 (<200)/0 CHF','300 (<6000)/0 CZK','4,90 (<100)/0 EUR','39 (<900)/0 DKK','299 (<5000)/0 EEK','9,90 (<250)/0 EUR','3,90 (<100)/0 GBP','3000 (<70000)/0 HUF','4000 (<70000)/0 JPY','13,90 (<200)/0 LVL','99 (<2500)/0 NOK','39 (<1000)/0 PLN','1000 (<20000)/0 RUB','49 (<2500)/0 SEK','29 (<600)/0 USD','19,90 (<600)/0 EUR','0 EUR','0 CHF') NOT NULL default '19,90 (<500)/0 EUR'"
                      => { data_type => 'enum', extra => { list => ['19,90 (<500)/0 EUR','4,90 (<120)/0 EUR','7,90 (<200)/0 CHF','300 (<6000)/0 CZK','4,90 (<100)/0 EUR','39 (<900)/0 DKK','299 (<5000)/0 EEK','9,90 (<250)/0 EUR','3,90 (<100)/0 GBP','3000 (<70000)/0 HUF','4000 (<70000)/0 JPY','13,90 (<200)/0 LVL','99 (<2500)/0 NOK','39 (<1000)/0 PLN','1000 (<20000)/0 RUB','49 (<2500)/0 SEK','29 (<600)/0 USD','19,90 (<600)/0 EUR','0 EUR','0 CHF'] }, default_value => '19,90 (<500)/0 EUR' },
    },
    extra => {
        create => [
            q{
                CREATE TABLE `mysql_loader-test1` (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    value varchar(100)
                )
            },
            q{
                CREATE VIEW mysql_loader_test2 AS SELECT * FROM `mysql_loader-test1`
            },
        ],
        pre_drop_ddl => [ 'DROP VIEW mysql_loader_test2', ],
        drop => [ 'mysql_loader-test1', ],
        count => 2,
        run => sub {
            my ($schema, $monikers, $classes) = @_;

            is $monikers->{'mysql_loader-test1'}, 'MysqlLoaderTest1',
                'table with dash correctly monikerized';

            my $rsrc = $schema->resultset($monikers->{mysql_loader_test2})->result_source;

            is $rsrc->column_info('value')->{data_type}, 'varchar',
                'view introspected successfully';
        },
    },
);

if( !$dsn || !$user ) {
    $tester->skip_tests('You need to set the DBICTEST_MYSQL_DSN, _USER, and _PASS environment variables');
}
else {
    diag $skip_rels_msg if not $test_innodb;
    $tester->run_tests();
}

# vim:et sts=4 sw=4 tw=0:
