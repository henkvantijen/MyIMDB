package MyIMDB::Basket;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mail::Sendmail qw(sendmail %mailcfg);
use MyIMDB::Models::Users;
use MyIMDB::Models::Movies;

use Data::Dumper;

# this method just renders the template and displays the basket's content
sub view {
	my $self = shift;

	if( !$self->session('name') ){
		$self->flash(login => 'You have to log in first');
		return $self->redirect_to('/login');
	}
}	

# this method creates or adds to the session the basket hash with the movie ids as hashes
sub buyMovie {
	my $self = shift;
	
	if( !$self->session('name') ){
		$self->flash(login => 'You have to log in first');
		return $self->redirect_to('/login');	
	}

	my $movie_id = $self->param('id');
	my $movie = MyIMDB::Models::Movies->retrieve($movie_id);

	$self->session->{basket}->{$movie_id} = { name => $movie->name() };
	$self->session->{basket}->{$movie_id}->{id} = $movie->id();
	$self->session->{basket}->{$movie_id}->{quantity} = 1 ;

	$self->redirect_to('/basket/view');
}

# this method updates the quantity of movies
# TO FINISH 
sub update {
	my $self = shift;

	my @q = $self->param('quantity'); 
	print Dumper( \@q );

	$self->redirect_to('/basket/view');
}

# this method deletes the basket hash from session
sub empty {
	my $self = shift;

	delete $self->session->{basket};

	$self->redirect_to('/basket/view');
}

# this method takes the id of the movie as a parameter and deletes the respective key from the hash
sub delete {
	my $self = shift;

	my $movie_id = $self->param('id');

	if( $movie_id !~ /\d+/ ){
		return $self->redirect_to('/404');
	}

	print Dumper($movie_id);
	delete $self->session->{basket}->{$movie_id};

	$self->redirect_to('/basket/view');
}

# this method is used to render the checkout details
sub checkout {
	my $self = shift;

	my $user_name = $self->session('name');
	my $user = MyIMDB::Models::Users->retrieve( name => $user_name );

	$self->stash( user => $user );
}

# this metod is used to retrieve the updated user detail and send a mail with the basket
# TO FINISH
sub sendEmail {
	my $self = shift;

	my $user_name = $self->param('name');
	my $user_email = $self->param('email');

	my %mail = ( To => "$user_email",
			  From => 'basket@my-imdb.com',
			  Message => "Basket"
		    );
	
	sendmail(%mail) or die $Mail::Sendmail::error;
	$mailcfg{smtp} = [qw(localhost 127.0.0.1)];

	$self->redirect_to('basket/view');
}

1;
