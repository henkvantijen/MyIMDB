package MyIMDB::Models::MoviesCommentsUsers;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('movies_comments_users');

__PACKAGE__->has_a( movie_id => 'MyIMDB::Models::Movies' );
__PACKAGE__->has_a( comment_id => 'MyIMDB::Models::Comments' );
__PACKAGE__->has_a( user_id => 'MyIMDB::Models::Users' );

1;
