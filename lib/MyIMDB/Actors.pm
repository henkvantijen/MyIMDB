package MyIMDB::Actors;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use MyIMDB::Models::Actors;

use Data::Dumper;

sub list {
	my $self = shift;

	my @list = MyIMDB::Models::Actors->retrieve_all;


	$self->render(objs => \@list);
}

sub details {
	my $self = shift;

	my $actor_id = $self->param('id');

	if( $actor_id !~ /\d+/ ){
		return $self->redirect_to('/404');
	}

	my $actor = MyIMDB::Models::Actors->retrieve($actor_id);

	if( $self->session('name') ){
	    my $user_name = $self->session('name');
	    my $user = MyIMDB::Models::Users->retrieve( name => $user_name );
	    my $user_id = $user->id();
			 
		my %search_keys = ( user_id => $user_id, actor_id => $actor_id );
		my $user_actor = MyIMDB::Models::UsersActors->retrieve( %search_keys );

	 	if( $user_actor ) {
			#the key $actor->{favorited} contains the user's preference for this actor
			#eg: if 'y' the actor has been marked as 'favorite' and the user should not be able to mark it again
			if( $user_actor->favorited() ){
				$actor->{favorited} = $user_actor->favorited();
			}
       }
	}
	
	$self->render(actor => $actor);
}

sub markFavorite {
	my $self = shift;

	my $user_name = $self->session('name');
	my $actor_id = $self->param('id');

	#get the user id based on the session name
	my $user = MyIMDB::Models::Users->retrieve( name => $user_name );
	my $user_id = $user->id();

	my $user_actor = MyIMDB::Models::UsersActors->find_or_create({
		user_id => $user_id,
		actor_id => $actor_id
	});
	
	if ($user_actor) {
		$user_actor->favorited('y');
		$user_actor->update();
	}
	
	$self->redirect_to( "actors/$actor_id" );
}

1;
