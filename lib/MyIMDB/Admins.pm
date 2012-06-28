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
		print Dumper("in login, placed admin name in session\n");
		return $self->redirect_to( "/admin/$admin_name" );
	}

	$self->stash( error => 1 );
}

sub home {
	my $self = shift;

}

# this action is called with a routing bridge
# and it checks if the admin is logged in or not
# in case it isn't it redirects to the user login 
# and not to the admin login
sub auth {
	my $self = shift;

	if( $self->session('admin_name') ){
			return 1;
	}
	
	$self->redirect_to('/login');
	return 0;
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
