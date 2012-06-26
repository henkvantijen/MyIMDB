package MyIMDB::Admins;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use MyIMDB::Models::Admins;

use Data::Dumper;

sub login {
	my $self = shift;
	
	#get the admin name and password from template
	my $admin_name = $self->param('name');

	print Dumper( b($self->param('pwd'))->md5_sum );

	if( MyIMDB::Models::Admins->sql_login_count->select_val($admin_name, b($self->param('pwd'))->md5_sum) == 1 ){
		$self->session( admin_name => $admin_name );
		return $self->redirect_to( "/admin/$admin_name" );
	}

	$self->stash( error => 1 );
}

sub home {
	my $self = shift;

}

1;
