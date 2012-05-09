package MyIMDB::Models::Genres;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('genres');

__PACKAGE__->has_many( movies => 'MyIMDB::Models::MoviesGenres' );

1;
