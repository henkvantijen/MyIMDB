package MyIMDB::Search;

use Mojo::Base 'Mojolicious::Controller';
use MyIMDB::Models::Actor;
use MyIMDB::Models::Movie;

use Data::Dump qw/dump/;
use DDP;

#use MyIMDB::Models::Genres;
#use MyIMDB::Models::MoviesGenres;

sub home {
	my $self = shift;

	$self->render();
}

sub search {
	my $self = shift;
    
    my $search_query = $self->param('search');
    my $search_type = $self->param('type');
	
    my $search_result;
    my @search_result;
	my @movies;
	my @genres;

	if( $search_type =~ /actors/ ){
		$search_result = $self->_actors($search_query);
    } elsif( $search_type =~ /movies/ ){
	    $search_result = $self->_movies($search_query);
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
				  search_result => $search_result,
			  	  movies => \@movies,
			  	  genres => \@genres
			    );
}

sub _actors {
    my ($self, $name) = @_;
    
    my $found_actors = MyIMDB::Models::Actor::Manager->get_actors(
        query => 
        [
            last_name => { like => "%$name" },
        ],
    );

    my $actors = [];
    foreach my $actor (@$found_actors) {
        my $current = { first_name => $actor->first_name,
                        last_name  => $actor->last_name,
                        date_of_birth => $actor->date_of_birth,
                      };
        push @$actors, $current;
    }

    return $actors;
}   

sub _movies {
    my ($self, $name) = @_;

    my $movies_found = MyIMDB::Models::Movie::Manager->get_movies(
        query => 
        [
            name => { like => "%$name%" },
        ],
    );

    my $movies = [];
   
    @$movies = map {
        { name        => $_->name, 
          launch_date => $_->launch_date,
          rating      => $_->rating,
        } 
    } @$movies_found;

    return $movies;
}

1;
