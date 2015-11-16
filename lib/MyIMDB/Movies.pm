package MyIMDB::Movies;                 #controller
use Mojo::Base 'Mojolicious::Controller';

use MyIMDB::Models::Movie;
use MyIMDB::Models::UserMovie;
use Data::Dumper;
use DDP;
use Data::Dump qw/dump/;


sub search {
    my ($self, $query) = @_;
   
    my $found_movies = MyIMDB::Models::Movie::Manager->get_movies(
        query =>
        [
            name => { like => "%$query%" },
        ],
    );
 
    my $movies = [];

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
  return $self->redirect_to('/404') if( $movie_id !~ /\d+/ );
	my $movie = 'MyIMDB::Models::Movie'->new(id => $movie_id);
  $movie->load;

  $self->loggedin_user;
  
  my $user_movie = {};
	if ( $self->{user} ) {
		 my %search_keys = ( user_id => $self->{user}->id, movie_id => $movie->id );
		 $user_movie  = MyIMDB::Models::UserMovie->new( %search_keys );
		 $user_movie->load(speculative => 1); # or die $!;
  }
  
  $movie->moviecomments;
  $self->stash( user_movie => $user_movie ) ;  
	$self->stash( movie => $movie );
  $self->stash( page_caption => "Movie Details" );
}




sub set_rate {
	my $self = shift;

	my $u_rating = $self->param('rating');
	my $movie_id = $self->param('id');
	
  $self->loggedin_user;
  
	#search or insert a new entry in the users_movies table and mark the movie as 'rated' for this user
	my $user_movie = MyIMDB::Models::UserMovie->new(
		user_id  => $self->{user}->id,
		movie_id => $movie_id,
	  )->load_or_insert;
	

		$user_movie->rating($u_rating);
		$user_movie->save();

   #Calculate and update avg_rating of this movie
	
   my $q = '(SELECT AVG(rating) FROM users_movies WHERE movies.id = users_movies.movie_id)';
   my $movie = MyIMDB::Models::Movie->new (id =>  $movie_id)->load;
   $movie->avg_rating($q);
   $movie->save;

	 $self->redirect_to( "/movie/$movie_id" );
}




sub flag {
  my $self = shift;
  my $movie_id  = $self->param('id');
  $self->_flag($movie_id);
	$self->redirect_to( "/movie/$movie_id#flag" );
}

sub flag_pjax {
  my $self = shift;
  my $movie_id  = $self->param('id');
  
  $self->render( text => $self->_flag($movie_id)); 
}


sub _flag {
  my $self = shift;
	my $movie_id = shift;
	
  $self->loggedin_user;

	my $user_movie = MyIMDB::Models::UserMovie->new(
		user_id  => $self->{user}->id,
		movie_id => $movie_id
	)->load_or_insert; 

  $user_movie->flagged(($user_movie->flagged + 1) % 2);   # module % 2 toggles 0 <-> 1
  $user_movie->save();
  return  ($user_movie->flagged) ? "Flagged" : "Not flagged";
}  



sub comment {
	my $self = shift;

	my $movie_id = $self->param('id');
	my $comment  = $self->param('comment');
  $self->loggedin_user;

  # add new comment
	my $muc = MyIMDB::Models::MovieUserComment->new(
		movie_id   => $movie_id,
		user_id    => $self->{user}->id,
	);
  
  $muc->comment($comment);
  $muc->save;
  
  #load all comments
  my $movie = MyIMDB::Models::Movie->new(id => $movie_id )->load; 
	my @all_rows = $movie->moviecomments;

	$self->redirect_to( "/movie/$movie_id" );	
}

1;
