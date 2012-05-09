package MyIMDB::Models::UsersMovies;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('users_movies');

__PACKAGE__->has_a( user_id => 'MyIMDB::Models::Users');
__PACKAGE__->has_a( movie_id => 'MyIMDB::Models::Movies');

1;
