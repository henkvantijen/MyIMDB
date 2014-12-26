package MyIMDB::Models::Object;

use strict;
use warnings;

use MyIMDB::Models::Base;
use base qw(Rose::DB::Object);

sub init_db { MyIMDB::Models::Base->new }

1;
