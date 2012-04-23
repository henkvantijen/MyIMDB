package MyIMDB::Models::Movies;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('movies');

__PACKAGE__->has_many (genres => 'MyIMDB::Models::MoviesGenres');

1;
