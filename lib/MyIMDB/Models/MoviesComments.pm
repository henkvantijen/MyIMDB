package MyIMDB::Models::MoviesComments;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('movies_comments');

__PACKAGE__->has_a( movie_id => 'MyIMDB::Models::Movies' );
__PACKAGE__->has_a( comment_id => 'MyIMDB::Models::Comments' );

1;
