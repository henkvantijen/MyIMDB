package MyIMDB::Login;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use MyIMDB::Models::Users;

sub login {
	my $self = shift;
	
	#get username and password from template
    my $user_name = $self->param('name');
 
	if ( MyIMDB::Models::Users->sql_login_count->select_val($user_name, b($self->param('pwd'))->md5_sum) == 1 ){
	    $self->session( name => $user_name );
		return $self->redirect_to( "/user/$user_name" );
	}
	
 	$self->stash( error => 1 );
}

1;
