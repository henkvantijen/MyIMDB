package MyIMDB::Models::Actor;

use strict;
use warnings;

use base 'MyIMDB::DB::Object';

__PACKAGE__->meta->setup(
    table      => 'actors',
    columns    => [ qw(actor_id first_name last_name date_of_birth) ],
    pk_columns => 'actor_id',
    unique_key => 'actor_id',
);

__PACKAGE__->meta->make_manager_class('actors');

# __PACKAGE__->has_many( movies => 'MyIMDB::Models::UsersActors' ); 
1;
