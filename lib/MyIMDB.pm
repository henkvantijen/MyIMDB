package MyIMDB;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Routes
  my $r = $self->routes;

  # Normal route to controller
  
  
  # Home page routes
  $r->route('/')->to('home#home');
  $r->route('/home/search')->to('home#search');

  # Login and logout routes
  $r->route('/login')->via('get')->to( template => 'login/login' );
  $r->route('/login')->via('post')->to('login#login');
  $r->route('/logout')->to('logout#logout');

  # Join routes
  $r->route('/join')->via('get')->to( template => 'join/join' );
  $r->route('/join')->via('post')->to('join#join');

  # Actors routes
  my $actor = $r->bridge('/actors/:id')->to('actors#details', id=>[0,9]);
  $actor->route('/')->to('actors#details');
  $actor->route('/mark')->to('actors#markFavorite');

  # Movies routes
  my $movie = $r->bridge('/movies/:id')->to('movies#details', id=>[0,9]);
  $movie->route('/')->to('movies#details');
  $movie->route('/rate')->to('movies#setRank');
  $movie->route('/mark')->to('movies#markFavorite');
  $movie->route('/buy')->to('basket#buyMovie');

  # Users routes
  $r->route('/user/#user_name')->to('users#home');
  $r->route('/view_basket')->to('basket#view');
}

1;
