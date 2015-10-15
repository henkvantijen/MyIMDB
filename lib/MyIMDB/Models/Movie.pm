package MyIMDB::Models::Movie;

use strict;
use warnings;

use base 'MyIMDB::DB::Object';

use MyIMDB::Models::UserMovie;
use MyIMDB::Models::User;

local $Rose::DB::Object::Manager::Debug = 1;

__PACKAGE__->meta->setup(
    table      => 'movies',
    auto => 1,

    #columns    => [ qw(movie_id name launch_date duration rating) ],
    #pk_columns => 'id',
    #unique_key => 'id',
    # relationships =>
    # [
    #   movies =>
    #   {
    #     type       => 'one to many',
    #     class      => 'MyIMDB::Models::UserMovie',
    #     column_map => { id => 'movie_id' },
    #   },
    # ], 

    relationships =>
    [
      # Define "many to many" relationship 
      users =>
      {
        type      => 'many to many',
        map_class => 'MyIMDB::Models::UserMovie',

      },
    ],

);


__PACKAGE__->meta->make_manager_class('movies');

# do not remove until the setup is fully updated
#__PACKAGE__->has_many( genres => 'MyIMDB::Models::MoviesGenres' );
#__PACKAGE__->has_many( users => 'MyIMDB::Models::UsersMovies' );
#__PACKAGE__->has_many( users_comments => 'MyIMDB::Models::MoviesUsersComments' );

1;
