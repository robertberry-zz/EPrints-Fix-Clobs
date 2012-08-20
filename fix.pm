#!/usr/bin/perl
#
# Script to fix the broken CLOB fields in Oracle versions of EPrints 3.3.10.
#
# Author: Robert Berry <robert.berry@liverpool.ac.uk>

use autodie;
use strict;

use DBI;
use DBUtils qw(db_from_settings query_fetch_all query_exec);
use Data::Dumper;

use constant DB_SETTINGS_PATH => "db.yml";

my $settings = {
    user => "username here",
    password => "password here",
    sid => "sid here"
};

my $dbh = db_from_settings($settings);

=method tables_to_fix

Returns a list of all the tables containing CLOB fields that need to be
modified.

=cut

sub tables_to_fix {
    query_fetch_all $dbh, qq {
        SELECT TABLE_NAME
        FROM tabs
        WHERE TABLE_NAME LIKE '%__ORDERVALUES_EN'
    };
}

=method clobs

Given a table name, returns a list of the column names of CLOB fields.

=cut

sub clobs {
    my ($table) = @_;

    query_fetch_all $dbh, qq {
        SELECT column_name
        FROM user_tab_cols
        WHERE table_name = '$table'
        AND data_type = 'CLOB'
    };
}

=method truncate_table

Given a table name, truncates the table.

=cut

sub truncate_table {
    my ($table) = @_;

    query_exec $dbh, qq {
        TRUNCATE TABLE $table
    };
}

=method clobs_to_varchars

Given a table name and a list of clob names, converts those clobs to be
VARCHAR2(1000)s.

=cut

sub clobs_to_varchars {
    my ($table, $clobs) = @_;

    my $columns = join(",\n", map { qq{"$_->[0]"} } @{$clobs});
    my $new_columns = join(",\n", map { qq{"$_->[0]" VARCHAR2(1000)} } @{$clobs});

    query_exec $dbh, qq {
        ALTER TABLE $table DROP (
           $columns
        )
    };

    query_exec $dbh, qq {
        ALTER TABLE $table ADD (
           $new_columns
        )
    };
}

=method fix_table

Given a table with broken CLOB fields, fixes it.

=cut

sub fix_table {
    my ($table) = @_;

    my $clobs = clobs($table);

    return unless scalar(@{$clobs});

    truncate_table($table);
    clobs_to_varchars($table, $clobs);
}

=method commit

Commit changes to DB.

=cut

sub commit {
    query_exec $dbh, "COMMIT";
}

sub main {
    my $tables = tables_to_fix;

    for my $table (@{$tables}) {
        fix_table($table->[0]);
    }

    commit;
}

main unless caller;
