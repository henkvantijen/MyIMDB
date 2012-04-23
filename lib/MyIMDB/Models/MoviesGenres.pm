package MyIMDB::Models::MoviesGenres;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('movies_genres');

__PACKAGE__->has_a(movie_id => 'MyIMDB::Models::Movies');
__PACKAGE__->has_a(genre_id => 'MyIMDB::Models::Genres');

1;
