use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;
use DBI;

# General configuration params
# DB connection params
my $driver   = 'SQLite';
my $database = 'MyIMDB.db';
my $dsn      = "DBI:$driver:dbname=$database";
my $userID   = '';
my $password = '';
my $dbh;

note "Testing DB Connection";
lives_ok { $dbh = DBI->connect($dsn, $userID, $password, {RaiseError => 1}) }
    "Connected to DB";

