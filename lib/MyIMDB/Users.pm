package MyIMDB::Users;			#controller

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use MyIMDB::Models::User;

use Data::Dumper;

# this method is used to render users details, or homepage
# it retrieves the username from the url
# and fetches arrays with users favorite movies and actors
sub home {
	my $c = shift;
	# Get the user name from the URL 
	# because visitors and also other loged users can 
	# view this user's profiles
	my $user_name = $c->param('user_name');

	my $u = 'MyIMDB::Models::User'->new(user_name => $user_name);
	#local $Rose::DB::Object::Manager::Debug = 1;
	#print Dumper( $u->movies);
	$u->load or die $!;
	$u->movies or die $!;    # Rose BUG?  ->movies can not solely be called in template?

	$c->stash( user_name        => $user_name,
		   user_obj	    => $u,
	);
		
}



# this method is used for login
# it receives the user name and password from the login template 
# via POST request 
sub login {
	my $self = shift;
	
	#get username and password from template
	my $user_name = $self->param('name');
	#if ( MyIMDB::Models::User::Manager->get_users_count($user_name, b($self->param('pwd'))->md5_sum) == 1 ){
	if  (0) { #( MyIMDB::Models::User::Manager->get_users_count($user_name, b($self->param('pwd'))->md5_sum) == 1 ){
		$self->session( name => $user_name );
		return $self->redirect_to( "/user/$user_name" );
	}
				   
	$self->stash( error => 1 );
}

# this method is called whenever we want to make sure a user is logged in or not
sub auth {
	my $self = shift;
	
	if( $self->session('name') ){
			return 1;
	}

	$self->flash(login => 'You have to login first');
	$self->redirect_to('/login');
	return 0;  
}

# this method is called when the users wants to log out
# it just expires the session and redirects to home page
sub logout {
	my $self = shift;

	$self->session( expires => 1 );

	$self->redirect_to('/');
}

# this method is used to create new user accounts
# it takes user name, password and email address 
# as input parameters via POST request
sub join {
	my $uc = shift;
	my $user_name = $uc->param('user_name');
			 
	#check if we already have a user with the same user name or email address
	my $u = MyIMDB::Models::User::->new;
	#print Dumper $u;
	my $error = $u->validate( $user_name, $uc->param('pwd'), $uc->param('re-pwd'), $uc->param('email') );
	$uc->stash( error => $error );
	return if $error;

	#if not, we create a new user
	$u->save({
		name => $user_name,
		pass => b($uc->param('pwd'))->md5_sum,
		email => $uc->param('email')
	});
						  
	#auto-login the user
	$uc->session( name => $user_name );
	$uc->redirect_to("/user/$user_name");
}

1;
