package MyIMDB::Models::Movie::Manager;
use base qw(Rose::DB::Object::Manager);
sub object_class { 'MyIMDB::Models::Movie'}

local $Rose::DB::Object::Manager::Debug = 1;

__PACKAGE__->make_manager_methods('movies');
# class methods get_x, get_x_iterator, get_x_count, delete_x, update_x


sub get_all_movies 
  {
    shift->get_objects(object_class => 'MyIMDB::Models::Movie', @_);
  }

  
1;

#-----------------------------------
