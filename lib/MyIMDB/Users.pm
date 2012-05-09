package MyIMDB::Users;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use MyIMDB::Models::Users;
use MyIMDB::Models::UsersMovies;

use Data::Dumper;

sub home {
	my $self = shift;
	my $user_name = $self->param('username');
	
	#based on the user name, search the Users table for the id
	my $it = MyIMDB::Models::Users->search(name => $user_name);
	my $user_id;
	while (my $i = $it->next) {
		$user_id = $i->id();
	}

	my $user = MyIMDB::Models::Users->retrieve( $user_id );


	my @movieIDs;
	while (my $id = $user->movies->next) {
		push( @movieIDs, $id);
	}


	#print Dumper( $user->movies->id);
	print Dumper(  @movieIDs );
		
} 

1;
