package MyIMDB::Users;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use MyIMDB::Models::Users;

use Data::Dumper;

sub home {
	my $self = shift;

	# I'm gettin the user name from the URL 
	# because visitors and other loged users can 
	# view this user's profiles
	my $user_name = $self->param('user_name');

	# these two arrays will contain object instances from movies and actors table
	my @favorited_movies;
	my @favorited_actors;

	my $user = MyIMDB::Models::Users->retrieve( name => $user_name );

	#iterate through all the movies from users_movies table for this user
	foreach( $user->movies ){
		#if the movie is marked as favorited push the object into @favorited_movies 
		if( $_->favorited ){
			push( @favorited_movies, $_ );
		}
	}

	#for favorited actors it's the same as for favorited movies	
	foreach( $user->actors ){
		if( $_->favorited ){
			push( @favorited_actors, $_ );
		}
	}

	$self->stash( user_name => $user_name,
				  favorited_movies => \@favorited_movies,
				  favorited_actors => \@favorited_actors,
	);
		
} 

1;
