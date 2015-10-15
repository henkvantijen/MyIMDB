package MyIMDB::Models::Genres;

use strict;
use warnings;

use base 'MyIMDB::DB::Object';

__PACKAGE__->meta->setup(
    table      => 'genres',
    columns    => [ qw(genre_id genre) ],
    pk_columns => 'genre_id',
    unique_key => 'genre_id',
);

#__PACKAGE__->has_many( movies => 'MyIMDB::Models::MoviesGenres' );

1;
