package MyIMDB::Movie::Manager;
use Mojo::Base 'Mojolicious::Controller';
use MyIMDB::Models::Movie;
use Data::Dump qw/dump/;
sub search {
    my ($self, $query) = @_;

    my $found_movies = MyIMDB::Models::Movie::Manager->get_movies(
        query => [ name => { like => "%$query%" } ]
    );

    my $movies;
    @$movies = map {
        MyIMDB::Movie->new({
            name => $_->name,
            launch_date => $_->launch_date,
            rating => $_->rating,
        }) 
     } @$found_movies;
   
    return $movies;
}

1;
