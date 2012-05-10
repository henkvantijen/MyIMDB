package MyIMDB::Models::UsersActors;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('users_actors');

__PACKAGE__->has_a( user_id => 'MyIMDB::Models::Users' );
__PACKAGE__->has_a( actor_id => 'MyIMDB::Models::Actors' );

1;
