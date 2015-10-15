package MyIMDB;

use Mojo::Base 'Mojolicious';
use Data::Dump qw/dump/;
use Mojo::JWT;
use Minion;
use Mojolicious::Plugin::Config;
use Mojo::Log;

use Mojolicious::Renderer;
use MyIMDB::Users;  #for renderer;

# This method will run once at server start
sub startup {
  my $self = shift;
  $self->{'log'}  = Mojo::Log->new;
  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
 
  #TODO  get this working
  #my $config = plugin Config => {file => 'MyIMDB.config'};
  $self->secrets(['Smooth Dancing ;-)']);

#my $renderer = Mojolicious::Renderer->new;
push @{$self->renderer->classes}, 'MyIMDB::Users';

  # Routes
  my $r = $self->routes;

  # Normal route to controller
  # Home page routes
  $r->get('/')->to('search#home');
  $r->get('/home/search')->to('search#search');

  # Login and logout routes
  $r->get('/login')->to(template => 'users/login');
  $r->post('/login')->to('users#login');
  $r->get('/logout')->to('users#logout');

  # Join routes
  $r->get('/join')->to(template => 'users/join');
  $r->post('/join')->to('users#join');

  # Confirm route  (link from mail)
  $r->get('/confirm')->to('users#confirm');

  #Password forgotten and reset
  $r->get('/forgot')->to(template => 'users/forgot');
  $r->post('forgot')->to('users#forgot');
  $r->get('reset')->to('users#reset');

  
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
  $basket->route('/send')->to(action => 'sendEmail');

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

  # for the mails to be send, a minion worker process must be running. Start it with
  # sudo script/my_imdb minion worker &

  $self->helper(
    send_email => sub {
      my ($c, $address, $subject, $body) = @_;
      use Email::Send::SMTP::Gmail;
      my $mail = Email::Send::SMTP::Gmail->new(
        -smtp  => 'smtp.gmail.com',
        -login => 'henkvantijen@gmail.com',
        -pass  => 'gm31l1963',
        -debug => 1
      );
      $mail->send(-to => $address, -subject => $subject, -body => $body, -verbose => '1') or die $!;
      $mail->bye;
    }
  );

  $self->helper(
    jwt => sub {
      Mojo::JWT->new(
        secret => shift->app->secrets->[0] || die
        );
    }
  );

  $self->plugin('Minion' => {File => '/var/www/html/MyIMDB/minion.db'});

  $self->minion->add_task(email_task => sub {shift->app->send_email(@_)});

  $self->helper(enqueue_email => sub {shift->minion->enqueue(email_task => [@_])});

}    #end startup()

1;

# ex: set tabstop=2 shiftwidth=2 expandtab:

