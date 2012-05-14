package MyIMDB::Join;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use MyIMDB::Models::Users;

sub join {
	my $self = shift;
	my $user_name = $self->param('user_name');
	
	#check if we already have a user with the same user name or email address
	my $error = MyIMDB::Models::Users->validate( $user_name, $self->param('pwd'), $self->param('re-pwd'), $self->param('email') ); 
	$self->stash( error => $error );
	return if $error;

	#if not, we create a new user
	MyIMDB::Models::Users->insert({
		name => $user_name,
		pass => b($self->param('pwd'))->md5_sum,
		email => $self->param('email')
		});


	#auto-login the user
	$self->session( name => $user_name );
	$self->redirect_to("/user/$user_name");
}

1;
