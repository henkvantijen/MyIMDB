package MyIMDB::Models::Actors;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('actors');
__PACKAGE__->has_many( movies => 'MyIMDB::Models::UsersActors' );

1;
