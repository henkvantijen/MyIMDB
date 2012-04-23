package MyIMDB::Actors;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use MyIMDB::Models::Actors;

use Data::Dumper;

sub list {
	my $self = shift;

	my @list = MyIMDB::Models::Actors->retrieve_all;


	$self->render(objs => \@list);
}

sub details {
	my $self = shift;

	my $id = $self->param('id');

	my $actor = MyIMDB::Models::Actors->retrieve($id);

	$self->render(actor => $actor);

}


1;
