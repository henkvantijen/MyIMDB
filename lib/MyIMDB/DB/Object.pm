package MyIMDB::DB::Object;

use MyIMDB::DB;
use base qw(Rose::DB::Object);

local $MyIMDB::DB::Object::Debug = 1;



sub init_db { MyIMDB::DB::->new }

1;
