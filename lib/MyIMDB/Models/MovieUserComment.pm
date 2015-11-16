package MyIMDB::Models::MovieUserComment;

use strict;
use warnings;

use base qw(MyIMDB::DB::Object);

#use MyIMDB::Models::Movie;
#use MyIMDB::Models::User;

__PACKAGE__->meta->setup (
    table      => 'comments',
    auto       => 1,

  foreign_keys =>
      [
        # Define foreign keys that point to each of the two classes 
        # that this class maps between.
        movie  => 
        {
          type  => 'many to one',
          class => 'MyIMDB::Models::Movie',
          key_columns => { movie_id => 'id' },
        },
   
        user => 
        {
          type  => 'many to one',
          class => 'MyIMDB::Models::User',
          key_columns => { user_id => 'id' },
        },
      ],

);

1;

#------------------------------------------------------------------------------


package MyIMDB::Models::MovieUserComment::Manager;
use base qw(Rose::DB::Object::Manager);
sub object_class { 'MyIMDB::Models::MovieUserComment'}

__PACKAGE__->make_manager_methods('movieusercomments');
# class methods get_x, get_x_iterator, get_x_count, delete_x, update_x




1;
