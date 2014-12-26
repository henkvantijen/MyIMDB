package UserRoles;

use strict;
use warnings;

use base 'MyIMDB::Models::Object';

__PACKAGE__->meta->setup(
    table => 'user_roles',
    columns => [ qw(user_id role_id) ],
    pk_columns => [ qw(user_id role_id) ],
    foreign_keys => [ qw(users roles) ],
);

1;
