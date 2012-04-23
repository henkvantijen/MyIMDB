package MyIMDB::Logout;

use strict;
use warnings;

use base 'Mojolicious::Controller';

sub logout {
	my $self = shift;
	$self->session( expires => 1 );
	$self->redirect_to('/');
}

1;
