package MyIMDB::Models::Comments;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('comments');

__PACKAGE__->has_many( users => 'MyIMDB::Models::Users' );
__PACKAGE__->has_many( movies => 'MyIMDB::Models::Movies' );

1;
