package MyIMDB::Models::Base;

use strict;
use warnings;

use base 'Class::DBI::mysql';

MyIMDB::Models::Base->connection('DBI:mysql:database=MyIMDB;host=127.0.0.1','root','as')
								or die "couldn't connect to db $!\n";
1;
