package MyIMDB::Login;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use MyIMDB::Models::Users;

sub login {
	my $self = shift;
	
	#received username and password from client
    my $username = $self->param('name');
	#my $password = $self->param('pass');
 
	if ( MyIMDB::Models::Users->sql_login_count->select_val( $username, b($self->param('pwd'))->md5_sum ) == 1 ) {
	    $self->session( name => $username );
		 return $self->redirect_to('/');
	}
	
 	$self->stash( error => 1 );
}

1;
