package MyIMDB::Users::Admins;
use base 'MyIMDB::Users';

use strict;
use warnings;

use MyIMDB::Models::User;
use MyIMDB::Models::User::Manager;
use Data::Dumper;



sub home {
	my $self = shift;
  $self->stash( page_caption =>  'Admin Home');

}


# check if the user is an admin or not and is logged in or not
# in case it isn't, redirect to the user login 
sub auth_admin {
	my $self = shift;
  my $admin_name = $self->param('user_name');
  
  return $self->session('admin');
  
  my $u = MyIMDB::Models::User->new(user_name => $admin_name)->load;

	if( $u->is_admin) {
		$self->session( admin => 1 );
		return $self->redirect_to( "/admin/$admin_name" );
	}


	#if( $self->session('admin') ) {
	#		return 1;
	#}
	$self->session(admin => undef );
	$self->redirect_to('/login');
	#return 0;
}

# logout method that expires the session
# and redirects to home page
sub xxxlogout{
	my $self = shift;

	$self->session( expires => 1);

	$self->redirect_to('/');
}

sub all_users {
	my $self = shift;

	my $all_users = MyIMDB::Models::User::Manager->get_users;

	$self->stash( all_users => $all_users );
  $self->stash( page_caption =>  'Admin All Users');
}

# this method will show user details
sub userDetails {
	my $self = shift;

	my $user_name = $self->param('user_name');
	my $user = MyIMDB::Models::User->get_users( name => $user_name );

	# we create a hash to organize the comments as anonymous hashes
	# under the same movie name as a key
	my %comments;

	foreach( $user->comments ){
		$comments{$_->movie_id->name}->{$_->comment_id} = $_->comment;
	}

	$self->stash( user => $user,
   				  comments =>\%comments	);
}

sub toggle_blocked {
	my $self = shift;

	my $user_id = $self->param('id');
	
	my $u = MyIMDB::Models::User->new( id => $user_id )->load;
  $u->is_blocked(($u->is_blocked + 1) % 2);
  $u->save;
	
	$self->redirect_to( "/admin/users/all" );
}

1;
