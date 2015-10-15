package MyIMDB::Models::UserRoleTypes;

use strict;
use warnings;

use base 'MyIMDB::DB::Object';

__PACKAGE__->meta->setup(
    table      => 'user_role_types',
    columns     => [ qw(role_id type) ],
    pk_columns => 'role_id',
    unique_key => 'role_id',
);

1;
