package MyIMDB::Basket;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use MyIMDB::Models::Users;
use MyIMDB::Models::Movies;
use Data::Dumper;

sub view {
	my $self = shift;

	if( !$self->session('name') ){
		$self->flash(login => 'You have to log in first');
		return $self->redirect_to('/login');
	}

	#my $user_name = $self->session('name');
	#my $user = MyIMDB::Models::Users->retrieve( name => $user_name );

	#my $basket = $self->session('basket');

	#$self->stash( basket => $basket );
	#
	#$self->session(expires => 1);
}	


sub buyMovie {
	my $self = shift;
	
	if( !$self->session('name') ){
		$self->flash(login => 'You have to log in first');
		return $self->redirect_to('/login');	
	}

	my $movie_id = $self->param('id');
	my $movie = MyIMDB::Models::Movies->retrieve($movie_id);

	$self->session->{basket}->{$movie_id} = { name => $movie->name() };
	$self->session->{basket}->{$movie_id}->{quantity} = 1 ;

	#print Dumper($self->session);

	$self->redirect_to( "/view_basket" );
}


1;
