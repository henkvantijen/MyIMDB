package MyIMDB::Home;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use MyIMDB::Models::Actors;
use MyIMDB::Models::Movies;
use MyIMDB::Models::Genres;
use MyIMDB::Models::MoviesGenres;

sub home {
	my $self = shift;

	$self->render();
}

sub search {
	my $self = shift;

	my $search_query = $self->param('search');
	my $search_type = $self->param('type');
	my @search_result;
	my @movies;
	my @genres;

	if( $search_type =~ /actors/ ){
		@search_result = MyIMDB::Models::Actors->search_like( name => "%$search_query%" );
	} elsif( $search_type =~ /movies/ ){
		@search_result = MyIMDB::Models::Movies->search_like( name => "%$search_query%" );
	} elsif( $search_type =~ /genres/ ){
		
		#search for the genre_id in the Genres table
		@genres = MyIMDB::Models::Genres->search_like( genre => "%$search_query%" );
		
		foreach my $genre ( @genres ){
			my $genre_id = $genre->id();

			#iterate over the joining table to get every movie_id for that genre
			my $it = MyIMDB::Models::MoviesGenres->search_like( genre_id => "$genre_id" );

			eval {
				while( my $mv = $it->next) {
					my $movie = MyIMDB::Models::Movies->retrieve(%{$mv->movie_id});
					push @movies, $movie;
				}
			}
		}
	}

	$self->stash( search_query => \$search_query,
				  search_type => $search_type,
				  search_result => \@search_result,
			  	  movies => \@movies,
			  	  genres => \@genres
			    );
}

1;
