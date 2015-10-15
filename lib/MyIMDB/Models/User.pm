package MyIMDB::Models::User::Manager;
use base qw(Rose::DB::Object::Manager);
sub object_class { 'MyIMDB::Models::User'}

__PACKAGE__->make_manager_methods('users');
# class methods get_x, get_x_iterator, get_x_count, delete_x, update_x

sub get_users_count_ {
  my $um = shift;
  __PACKAGE__->get_users_count(@_);
}
1;

#------------------------------------------------------------------------------

package MyIMDB::Models::User;
use strict;
use warnings;

use base qw(MyIMDB::DB::Object);

__PACKAGE__->meta->setup (
    table      => 'users',
    unique_key => ['user_name', 'id', 'email'],
#    columns =>
#    [
#      email_validated => { type => 'boolean' },
#    ],
#
    auto       => 1,
    
    relationships => 				# Define "many to many" relationship 
    [
      movies =>
      {
        type         => 'many to many',
        map_class    => 'MyIMDB::Models::UserMovie',
        manager_args => { with_map_records => 1 },    # force users_movie records to be accessible
      },
    ],


);


#TODO legacy dbix to convert to rose:
#__PACKAGE__->has_many( actors => 'MyIMDB::Models::UsersActors' );
#__PACKAGE__->has_many( comments => 'MyIMDB::Models::MoviesUsersComments' );

# this query is called when the users wants to login
#__PACKAGE__->set_sql( login_count => qq{
#    SELECT COUNT(*) FROM __TABLE__ WHERE name=? AND pass=?
#});






sub validate {
	my $self = shift;
	my ($user, $pass, $pass2, $email) = @_;

	return 'username field must not be blank' unless $user and length $user;
	
	return 'this user already exists'
		if 'MyIMDB::Models::User::Manager'->get_users_count(query => [user_name => $user]) > 0;

	return 'password field must not be blank' unless $pass and length $pass;
	
	return 'please re-type your password' unless $pass2 and length $pass2;
	
	return 'passwords don\'t match' unless $pass eq $pass2;
	
	return 'email field must not be blank' unless $email and length $email;

	return 'not e valid email address, must be like \'name@service.domain\'' 
		unless $email =~ /\w+@\w+\.\w+/i;

	return 'this email address is already registered'
		if 'MyIMDB::Models::User::Manager'->get_users_count(query => [email => $email]) > 0;
	
	return;
}



1;
