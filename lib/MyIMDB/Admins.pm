package MyIMDB::Admins;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use MyIMDB::Models::Admins;
use MyIMDB::Models::Users;

use Data::Dumper;

sub login {
	my $self = shift;
	
	#get the admin name and password from template
	my $admin_name = $self->param('name');

	if( MyIMDB::Models::Admins->sql_login_count->select_val($admin_name, b($self->param('pwd'))->md5_sum) == 1 ){
		$self->session( admin_name => $admin_name );
		return $self->redirect_to( "/admin/$admin_name" );
	}

	$self->stash( error => 1 );
}

sub home {
	my $self = shift;

}

sub allUsers {
	my $self = shift;

	my @all_users = MyIMDB::Models::Users->retrieve_all;

	$self->stash( all_users => \@all_users );
}

sub deleteUser {
	my $self = shift;

	my $user_id = $self->param('id');
	
	MyIMDB::Models::Users->search( id => $user_id )->delete_all;
	
	$self->redirect_to( "/admin/users/all" );
}

1;
