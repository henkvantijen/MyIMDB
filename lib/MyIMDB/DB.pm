package MyIMDB::DB;

#use strict;
#use warnings;

use base qw(Rose::DB);
#use Carp::Always;

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db(
    driver   => 'SQLite',
    database => 'MyIMDB.db',
    host     => 'localhost',
    username => '',
    password => '',
);

1;
