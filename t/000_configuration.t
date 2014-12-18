use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;
use DBI;

use Cwd;

my $cwd = getcwd();
# General configuration params
# DB connection params
my $driver   = 'SQLite';
my $database =  $cwd . '/MyIMDB.db';
my $dsn      = "DBI:$driver:dbname=$database";
my $userID   = '';
my $password = '';
my $dbh;

note $dsn;
note "Testing DB Connection";
lives_ok { $dbh = DBI->connect($dsn, $userID, $password, {RaiseError => 1}) }
    "Connected to DB";

note "Testing MyIMDB::Models::DB";
require_ok "MyIMDB::Models::DB", "loads up nicely";

