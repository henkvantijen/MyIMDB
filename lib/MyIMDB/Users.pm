package MyIMDB::Users;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use MyIMDB::Models::Users;

use Data::Dumper;

sub home {
	my $self = shift;
	my $user_name = $self->param('username');
	my @favorited_movies;
	
	#based on the user name, search the Users table for the id
	my $it = MyIMDB::Models::Users->search(name => $user_name);
	my $user_id;
	while (my $i = $it->next) {
		$user_id = $i->id;
	}
	my $user = MyIMDB::Models::Users->retrieve( $user_id );

	#iterate through all the movies from users_movies table for this user
	foreach( $user->movies ){
		#if the movie is marked as favorited push it into @favorited_movies 
		if( $_->favorited ){
		   	print Dumper ($_->movie_id->name);
			push (@favorited_movies, $_->movie_id->name);
		}
	}
	
	$self->stash( favorited_movies => \@favorited_movies );
		
} 

1;
