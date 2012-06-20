package MyIMDB::Home;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use MyIMDB::Models::Actors;
use MyIMDB::Models::Movies;
use MyIMDB::Models::Genres;
use MyIMDB::Models::MoviesGenres;

use Data::Dumper;

sub home {
	my $self = shift;

	$self->render();
}

sub search {
	my $self = shift;

	my $search_query = $self->param('search');
	my $search_type = $self->param('type');
	my @search_result;

	#a return hash is constructed with all the details we need in the template
	my %return_result = (
		search_query => $search_query,
		search_type => $search_type,
	);


	if ($search_type =~ /actors/){
		@search_result = MyIMDB::Models::Actors->search_like( name => "%$search_query%" );
		$return_result{search_result} = \@search_result;

		$self->stash (return_result => \%return_result);

	} elsif ($search_type =~ /movies/){
	    @search_result = MyIMDB::Models::Movies->search_like( name => "%$search_query%" );
		$return_result{search_result} = \@search_result;

		$self->stash (return_result => \%return_result);
	
	} elsif ($search_type =~ /genres/){
		my @movies;	
		
		#search for the genre_id in the Genres table
	  	my @genres = MyIMDB::Models::Genres->search_like (genre => "%$search_query%");

		$return_result{genres} = \@genres;

		#for every genre_id get the movies_id from the joining table (MoviesGenres)
		#for every movie_id, push it in the @movies array
		foreach my $genre (@genres) {
			my $genre_id = $genre->id();

			#iterate over the joining table to get every movie_id for the specific genre_id
			my $it = MyIMDB::Models::MoviesGenres->search_like (genre_id => "$genre_id");
	
			eval {
				while (my $mv = $it->next) {
					my $movie = MyIMDB::Models::Movies->retrieve(%{$mv->movie_id});
					push @movies, $movie;
				}
			}
		}
		
		$return_result{movies} = \@movies;	
				
		$self->stash (return_result => \%return_result);
	}
}

sub search2 {
	my $self = shift;

	my $search_query = $self->param('search');
	my $search_type = $self->param('type');
	my @search_result;
	my @movies;

	if( $search_type =~ /actors/ ){
		@search_result = MyIMDB::Models::Actors->search_like( name => "%$search_query%" );
	} elsif( $search_type =~ /movies/ ){
		@search_result = MyIMDB::Models::Movies->search_like( name => "%$search_query%" );
	} elsif( $search_type =~ /genres/ ){
		
		#search for the genre_id in the Genres table
		my @genres = MyIMDB::Models::Genres->search_like( genre => "%$search_query%" );
		
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
			  	  movies => \@movies 
			    );
}

1;
