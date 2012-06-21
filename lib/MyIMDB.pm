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
  my $actor = $r->route('/actors/:id')->to('actors#details');
  $actor->route('/')->to('actors#details');
  $actor->route('/mark')->to('actors#markFavorite');

  # Movies routes
  my $movie = $r->route('/movies/:id')->to(controller => 'movies');
  $movie->route('/')->to(action => 'details');
  $movie->route('/rate')->to(action => 'setRate');
  $movie->route('/mark')->to('movies#markFavorite');
  $movie->route('/buy')->to('basket#buyMovie');

  # Users routes
  $r->route('/user/#user_name')->to('users#home');

  # Basket routes
  my $basket = $r->route('/basket')->to(controller => 'basket');
  $basket->route('/view')->to(action => 'view');
  $basket->route('/update')->to(action => 'update');
  $basket->route('/empty')->to(action => 'empty');
  $basket->route('/delete/:id')->to(action => 'delete');
  $basket->route('/checkout')->to(action => 'checkout');
  $basket->route('/send')->to(action =>'sendEmail');

  # Error routes
  $r->route('/404')->to(template => 'errors/404');
}

1;
