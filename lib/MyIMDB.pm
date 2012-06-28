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
  my $actor = $r->route('/actors/:id')->to(controller => 'actors');
  $actor->route('/')->to(action => 'details');
  $actor->post('/mark')->to(action => 'markFavorite');

  # Movies routes

  #my $movie = $r->bridge->to('users#auth')->route('/movies/:id')->to(controller => 'movies');
  my $movie = $r->route('/movies/:id')->to(controller => 'movies');
  $movie->route('/')->to(action => 'details');
  $movie->post('/rate')->to(action => 'setRate');
  $movie->post('/mark')->to(action => 'markFavorite');
  $movie->route('/buy')->to('basket#buyMovie');
  $movie->post('/comment')->to(action => 'comment');

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
  #my $admin = $r->route('/admin')->to(controller => 'admins');
  #$admin->route('/login')->via('get')->to(template => 'admins/login');
  #$admin->route('/login')->via('post')->to(action => 'login');

  $r->route('/admin_login')->via('get')->to(template => 'admins/login');
  $r->route('/admin_login')->via('post')->to('admins#login');

  #my $admin = $r->under('/admin');
  my $admin = $r->bridge('/admin')->to('admins#auth');
  $admin->route('/')->to(controller => 'admins');
  #$admin->route('/')->to(controller => 'admins');
  $admin->route('/#admin_name')->to(action => 'home');
  $admin->route('/users/all')->to(action => 'allUsers');
  $admin->route('/users/:id/delete')->to(action => 'deleteUser');
  $admin->route('/users/search')->to(action => 'searchUsers');

  # Error routes
  $r->route('/404')->to(template => 'errors/404');
}

1;
