package MyIMDB;

use Mojo::Base 'Mojolicious';
use Data::Dump qw/dump/;


# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # Routes
    my $r = $self->routes;
  
  # Normal route to controller
  # Home page routes
  $r->get('/')->to('search#home');
  $r->get('/home/search')->to('search#search');

  # Login and logout routes
  $r->get('/login')->to( template => 'users/login' );
  $r->post('/login')->to('users#login');
  $r->get('/logout')->to('users#logout');

  # Join routes
  $r->get('/join')->to( template => 'users/join' );
  $r->post('/join')->to('users#join');

  # Actors routes
  my $actor = $r->route('/actors/:id')->to(controller => 'actors');
  $actor->route('/')->to(action => 'details');
  
  # we create an routing bridge (Mojo 6: under) to check if the user is logged in or not
  $actor->under('/')->to('users#auth')->post('/mark')->to('actors#markFavorite');

  # Movies routes
  my $movie = $r->route('/movies/:id')->to(controller => 'movies');
  $movie->route('/')->to(action => 'details');
  $movie->route('/buy')->to('basket#buyMovie');
  
  $movie->under('/')->to('users#auth')->post('/rate')->to('movies#setRate');
  $movie->under('/')->to('users#auth')->post('/mark')->to('movies#markFavorite');
  $movie->under('/')->to('users#auth')->post('/comment')->to('movies#comment');

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

  # Admin routes
  $r->get('/admin_login')->to(template => 'admins/login');
  $r->post('/admin_login')->to('admins#login');

  # this bridge (Mojo 6: under) is used to always check if and admin is logged in or not
  # so that the actions below will execute or...not 
  my $admin = $r->under('/admin')->to('admins#auth');
  $admin->route('/')->to(controller => 'admins');
  $admin->route('/#admin_name')->to(action => 'home');
  $admin->route('/users/all')->to(action => 'allUsers');
  $admin->route('/users/:id/delete')->to(action => 'deleteUser');
  $admin->route('/users/search')->to(action => 'searchUsers');
  $admin->route('/users/#user_name')->to(action => 'userDetails');

  # Error routes
  $r->route('/404')->to(template => 'errors/404');
}

1;
