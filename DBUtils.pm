package DBUtils;

use strict;
use Exporter;
use DBI;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(db_from_settings query_fetch_all prepare_or_die query_exec);

sub db_from_settings {
    my $settings = shift;

    DBI->connect('dbi:Oracle:'. $settings->{sid},
                           $settings->{user},
                           $settings->{password})
        or die "Could not connect to DB: $DBI::errstr";
}

sub prepare_or_die {
    my ($dbh, $sql) = @_;
    $dbh->prepare_cached($sql) or die "Error in SQL: $DBI::errstr";
}

sub query_fetch_all {
    my ($dbh, $sql) = @_;
    my $sth = prepare_or_die($dbh, $sql);
    $sth->execute();
    my $results = $sth->fetchall_arrayref;
    $sth->finish;
    $results;
}

sub query_exec {
    my ($dbh, $sql) = @_;

    my $sth = prepare_or_die($dbh, $sql);
    $sth->execute();
    $sth->finish();
}
