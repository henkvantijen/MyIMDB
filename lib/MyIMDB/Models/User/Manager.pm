package MyIMDB::Models::User::Manager;
use base 'Rose::DB::Object::Manager';

#use MyIMDB::Models::User;

sub object_class { 'MyIMDB::Models::User' }

__PACKAGE__->make_manager_methods('users');




1;
