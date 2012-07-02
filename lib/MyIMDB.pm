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
  $r->get('/login')->to( template => 'users/login' );
  $r->post('/login')->to('users#login');
  $r->get('/logout')->to('users#logout');

  # Join routes
  $r->get('/join')->to( template => 'users/join' );
  $r->post('/join')->to('users#join');

  # Actors routes
  my $actor = $r->route('/actors/:id')->to(controller => 'actors');
  $actor->route('/')->to(action => 'details');
  $actor->post('/mark')->to(action => 'markFavorite');

  # Movies routes
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
  $r->route('/admin_login')->via('get')->to(template => 'admins/login');
  $r->route('/admin_login')->via('post')->to('admins#login');

  # this bridge is used to always check if and admin is logged in or not
  # so that the actions below will execute or...not 
  my $admin = $r->bridge('/admin')->to('admins#auth');
  $admin->route('/')->to(controller => 'admins');
  $admin->route('/#admin_name')->to(action => 'home');
  $admin->route('/users/all')->to(action => 'allUsers');
  $admin->route('/users/:id/delete')->to(action => 'deleteUser');
  $admin->route('/users/search')->to(action => 'searchUsers');

  # Error routes
  $r->route('/404')->to(template => 'errors/404');
}

1;
