package MyIMDB::Models::Users;

use strict;
use warnings;

use base 'MyIMDB::Models::Object';

__PACKAGE__->meta->setup(
    table => 'users',
    columns => [ qw(user_id name password email) ],
    pk_columns => 'user_id',
    unique_key => 'user_id',
);

#__PACKAGE__->has_many( movies => 'MyIMDB::Models::UsersMovies' );
#__PACKAGE__->has_many( actors => 'MyIMDB::Models::UsersActors' );
#__PACKAGE__->has_many( comments => 'MyIMDB::Models::MoviesUsersComments' );


# this query is called when the users wants to login
#__PACKAGE__->set_sql( login_count => qq{
#    SELECT COUNT(*) FROM __TABLE__ WHERE name=? AND pass=?
#});

# this query is called when the users wants to join
# it checks if there is already a registered user with the same name
#__PACKAGE__->set_sql( join_count => qq{
#		SELECT COUNT(*) FROM __TABLE__ WHERE name=?
#});


# this query is called when the users wants to join
# it checks if there is already a registered user with the same email
_#_PACKAGE__->set_sql( email_count => qq{
#		SELECT COUNT(*) FROM __TABLE__ WHERE email=?
#});

sub validate {
	my $self = shift;
	my ($user, $pass, $pass2, $email) = @_;

	return 'username field must not be blank' unless $user and length $user;
	
	return 'this user already exists'
		if __PACKAGE__->sql_join_count->select_val($user)>0;

	return 'password field must not be blank' unless $pass and length $pass;
	
	return 'please re-type your password' unless $pass2 and length $pass2;
	
	return 'passwords don\'t match' unless $pass eq $pass2;
	
	return 'email field must not be blank' unless $email and length $email;

	return 'not e valid email address, must be like \'name@service.domain\'' 
		unless $email =~ /\w+@\w+\.\w+/i;

	return 'this email address is already registered'
		if __PACKAGE__->sql_email_count->select_val($email)>0;
	
	return;
}

1;
