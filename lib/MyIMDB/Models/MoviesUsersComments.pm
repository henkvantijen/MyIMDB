package MyIMDB::Models::MoviesUsersComments;

use strict;
use warnings;

use base 'MyIMDB::Models::Base';

__PACKAGE__->set_up_table('movies_users_comments');

__PACKAGE__->has_a( movie_id => 'MyIMDB::Models::Movies' );
__PACKAGE__->has_a( user_id => 'MyIMDB::Models::Users' );

#__PACKAGE__->add_trigger( before_create => \&last_comment_id );

#sub last_comment_id {
#	my @all_rows = __PACKAGE__->retrieve_all;
#	my $last_row = pop @all_rows;
#	my $last_comment_id = $last_row->comment_id;
#	return $last_comment_id + 1 ;
#}

1;
