package MyIMDB::Models::UserMovie;

use strict;
use warnings;
use base qw(MyIMDB::DB::Object);

use MyIMDB::Models::Movie;
use MyIMDB::Models::User;

__PACKAGE__->meta->setup (
    table => 'users_movies',
    auto => 1,

	foreign_keys =>
	    [
	      # Define foreign keys that point to each of the two classes 
	      # that this class maps between.
	      movie  => 
	      {
	        class => 'MyIMDB::Models::Movie',
	        key_columns => { movie_id => 'id' },
	      },
	
	      user => 
	      {
	        class => 'MyIMDB::Models::User',
	        key_columns => { user_id => 'id' },
	      },
	    ],
);

1;




package MyIMDB::Models::UserMovie::Manager;
use base qw(Rose::DB::Object::Manager);

sub object_class { 'MyIMDB::Models::UserMovie' }

__PACKAGE__->make_manager_methods('usermovies');


1;


