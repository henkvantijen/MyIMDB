package MyIMDB::Models::UsersComments;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('users_comments');

__PACKAGE__->has_a( user_id => 'MyIMDB::Models::Users' );
__PACKAGE__->has_a( comment_id => 'MyIMDB::Models::Comments' );

1;
