package MyIMDB::Movie;
use Mojo::Base 'Mojolicious::Controller';

use MyIMDB::Models::Movie;
use Data::Dumper;
use DDP;
use Data::Dump qw/dump/;

# define attributes
# there are also accessor methods
has [qw/name launch_date rating/];

sub search {
    my ($self, $query) = @_;
   
    my $found_movies = MyIMDB::Models::Movie::Manager->get_movies(
        query =>
        [
            name => { like => "%$query%" },
        ],
    );
 
    my $movies = [];

#   version 1
#   foreach my $movie (@$found_movies) {
#       my $current = { 
#           name        => $movie->name,
#           launch_date => $movie->launch_date,
#           rating      => $movie->rating,
#       };
#       push @$movies, $current;
#   };

    # version 2
    @{$movies}  = map { 
        { name        => $_->name,
          launch_date => $_->launch_date,
          rating      => $_->rating,
        }
    } @$found_movies;
    
    return $movies;
}

sub details {
	my $self = shift;

	my $movie_id = $self->param('id');

	if( $movie_id !~ /\d+/ ){
		return $self->redirect_to('/404');
	}

	my $movie = MyIMDB::Models::Movies->retrieve($movie_id);

	my $rating = $movie->rating();

	# the key $movie->{rating} contains the total rating for this movie
	if( $rating == 0 ){
		$movie->{rating} = "No ratings yet";
	} else { 
		$movie->{rating} = $rating;
	}

	if( $self->session('name') ){
		my $user_name = $self->session('name');
		my $user = MyIMDB::Models::Users->retrieve( name => $user_name );
		my $user_id = $user->id();

		my %search_keys = ( user_id => $user_id, movie_id => $movie_id );
		my $user_movie = MyIMDB::Models::UsersMovies->retrieve( %search_keys );
		
		if( $user_movie ) {
			#the key $movie->{rated} contains the user's preference for this movie 
			#eg: if 'y' the movie has been rated and the user should not be able to rate it again
			if( $user_movie->rated() ){
				$movie->{rated} = $user_movie->rated();
			}
		
			#the key $movie->{favorited} contains the user's preference for this movie
			#eg: if 'y' the movie has been marked as 'favorite' and the user should not be able to mark it again
			if( $user_movie->favorited() ){
				$movie->{favorited} = $user_movie->favorited();
			}
		}
	}

	$self->stash( movie => $movie );
}

sub setRate {
	my $self = shift;

	my $new_rating = $self->param('rating');
	my $movie_id = $self->param('id');
	my $user_name = $self->session('name');
	
	#get the user id based on the session name
	my $user = MyIMDB::Models::Users->retrieve( name => $user_name );
	my $user_id = $user->id();
	
	#retrieve existing movie rating
	my $movie = MyIMDB::Models::Movies->retrieve($movie_id);
	my $old_rating = $movie->rating();

	#check rating and set it
	if( $old_rating == 0 ){
		$movie->rating( $new_rating );
		$movie->update();
	} else {
		my $rating = ( $old_rating + $new_rating ) / 2;
		$movie->rating( $rating );
		$movie->update();
	}

	#search or insert a new entry in the users_movies table and mark the movie as 'rated' for this user
	my $user_movie = MyIMDB::Models::UsersMovies->find_or_create({
		user_id => $user_id,
		movie_id => $movie_id,
	});
	
	if ($user_movie) {
		$user_movie->rated('y');
		$user_movie->update();
	}

	$self->redirect_to( "movies/$movie_id" );
}

sub markFavorite {
	my $self = shift;

	my $user_name = $self->session('name');
	my $movie_id = $self->param('id');
	
	#get the user id based on the session name
	my $user = MyIMDB::Models::Users->retrieve( name => $user_name );
	my $user_id = $user->id();
		
	my $user_movie = MyIMDB::Models::UsersMovies->find_or_create({
		user_id => $user_id,
		movie_id => $movie_id
	});

	if ($user_movie) {
		$user_movie->favorited('y');
		$user_movie->update();
	}

	$self->redirect_to( "movies/$movie_id" );
}

sub comment {
	my $self = shift;

	my $movie_id = $self->param('id');
	my $comment = $self->param('comment');

	my $user = MyIMDB::Models::Users->retrieve( name => $self->session('name') );
	my $user_id = $user->id();

	# For tables with multi-column primary keys you need to supply all the key values, 
	# either in the arguments to the insert() method, 
	# or by setting the values in a before_create trigger.
	# 
	# Unfortunately I coudn't set up the before_create trigger properly
	# so I've improvised on the spot

	my @all_rows = MyIMDB::Models::MoviesUsersComments->retrieve_all;
	my $last_row = pop @all_rows;
	my $last_comment_id = $last_row->comment_id;
	my $new_comment_id = $last_comment_id + 1;

	
	MyIMDB::Models::MoviesUsersComments->insert({
		movie_id => $movie_id,
		user_id => $user_id,
		comment_id => $new_comment_id,
		comment => $comment	
	});

	$self->redirect_to( "movies/$movie_id" );	
}

1;
