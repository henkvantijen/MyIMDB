package MyIMDB::Movies;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use MyIMDB::Models::Movies;

sub details {
	my $self = shift;

	my $id = $self->param('id');

	my $movie = MyIMDB::Models::Movies->retrieve($id);

	my $rank = $movie->rank();

	if ($rank == 0) {
		$movie->{rank} = "No ratings yet";
	} else { 
		$movie->{rank} = $rank;
	}

	$self->stash( movie => $movie );
}

sub setRank {
	my $self = shift;

	my $rank = $self->param('rank');
	my $id = $self->param('id');
	
	use Data::Dumper;
	print Dumper( $rank, $id);

	$self->render( template => 'movies/details/$id');
}

1;
