package MyIMDB::Users;			#controller

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use MyIMDB::Models::User;

use Data::Dumper;




# this method is used to render users details, or homepage
# it retrieves the username from the url
# and fetches arrays with users favorite movies and actors
sub home {
	my $c = shift;
	# Get the user name from the URL 
	# because visitors and also other loged users can 
	# view this user's profiles
	my $user_name = $c->param('user_name');

	my $u = 'MyIMDB::Models::User'->new(user_name => $user_name);
	#local $Rose::DB::Object::Manager::Debug = 1;
	#print Dumper( $u->movies);
	$u->load or die $!;
	$u->movies or die $!;    # Rose BUG?  ->movies can not solely be called in template?

	$c->stash( user_name        => $user_name,
		   user_obj	    => $u,
	);
}



# this method is used for login
# it receives the user name and password from the login template 
# via POST request 
sub login {
	my $self = shift;
	
	#get username and password from template
	my $user_name = $self->param('name');
	my $pwd_enc = b($self->param('pwd'))->md5_sum;
	if ( MyIMDB::Models::User::Manager->get_users_count (
          query =>
                 [
                   user_name     => $user_name,
                   password_enc  => "$pwd_enc",    #to string
                 ],
          )) { 
		$self->session( name => $user_name );
		return $self->redirect_to( "/user/$user_name" );
	}
				   
	$self->stash( error => 1 );
}

# this method is called whenever we want to make sure a user is logged in or not
sub auth {
	my $self = shift;
	
	if( $self->session('name') ){
			return 1;
	}

	$self->flash(login => 'You have to login first');
	$self->redirect_to('/login');
	return 0;  
}

# logout:  expires the session and redirects to home page
sub logout {
	my $self = shift;

	$self->session( expires => 1 );
        
	$self->session( anonymous => 1 );  #we need a new session for flash message

        $self->flash(message => qq(You're logged out.));

	$self->redirect_to('/');
}

# create new user accounts
# POST params: user name, password and email address 
sub join {
	my $uc = shift;
	my $user_name = $uc->param('user_name');
			 
	#check if we already have a user with the same user name or email address
	my $u = MyIMDB::Models::User::->new;
	#print Dumper $u;
	my $error = $u->validate( $user_name, $uc->param('pwd'), $uc->param('re-pwd'), $uc->param('email') );
	$uc->stash( error => $error );
	return if $error;

	#if no error, we create a new user
	$u->user_name($user_name);
	my $pwd =  b($uc->param('pwd'))->md5_sum;
	$u->password_enc("$pwd");    # tostring
	#print Dumper($u->password_enc);
	$u->email($uc->param('email'));
	$u->save;
	
						  
	#auto-login the user
	#$uc->session( name => $user_name );
	#$uc->redirect_to("/user/$user_name");

	$uc->setup_activation($u);
        $uc->flash(message => 'Link sent, check your mail now');
	$uc->redirect_to("/");
}


sub setup_activation {
    my $uc  = shift;
    my $u   = shift;
    my $jwt = $uc->jwt->claims({username => $u->user_name})->encode or die $!;
    my $url = $uc->url_for('confirm')->to_abs->query(jwt => $jwt) or die $!;
    
    $uc->stash(title => 'Confirm your e-mail',
        mailbody1 => '',
        mailbody2 => '',
        action_url => $url,
        action_label => 'Confirm Email',
        signoff => 'MyIMDB');
    my $mtemplate = $uc->render_to_string('/users/mail_action');
#print Dumper( $mtemplate);
    $uc->enqueue_email($u->email, qq ( $mtemplate )) or die $!;
}



sub confirm {
  my $self = shift;
  my $user_name = $self->jwt->decode($self->param('jwt'))->{username};
  my $u = MyIMDB::Models::User->new(user_name => $user_name);
  $u->load;
  if ($u->email_validated) {
         $self->flash(message => 'Already validated');
  } else {
    $u->email_validated(1);
    $u->save;
    $self->flash(message => 'Confirm success, login now');
  }
  $self->redirect_to("user/$user_name");
};


# send link to reset password
# POST params: email address
sub forgot {
        my $uc = shift;
        $uc->setup_reset($uc->param('email'));
        $uc->flash(message => 'Password Reset Link sent, check your mail now');
        $uc->redirect_to("/");
}

# send email to with link to reset password  (side-effect only)
sub setup_reset {
    my $uc  = shift;
    my $email  = shift;
    my $jwt = $uc->jwt->claims({email => $email})->encode or die $!;
    my $url = $uc->url_for('reset')->to_abs->query(jwt => $jwt) or die $!;

    $uc->stash(title => 'Reset your password-mail',
        mailbody1 => 'Someone (you) requested a password reset',
        mailbody2 => '',
        action_url => $url,
        action_label => 'Password Reset',
        signoff => 'MyIMDB');
    my $mtemplate = $uc->render_to_string('/users/mail_action');
#print Dumper( $mtemplate);
    $uc->enqueue_email($email, qq ( $mtemplate )) or die $!;
}



sub reset {
  my $self = shift;
  my $email = $self->jwt->decode($self->param('jwt'))->{email};
  my $u = MyIMDB::Models::User->new(email => $email);
  $u->load;
  # if ($u->email_validated) {
  #        $self->flash(message => 'Already validated');
  # } else {
  #   $u->email_validated(1);
  #   $u->save;
  #   $self->flash(message => 'Confirm success, login now');
  # }

  
  $self->render('users/password_reset');

};






# https://github.com/leemunroe/responsive-html-email-template/blob/master/email-inlined.html
1;



__DATA__


@@ transactmail.html.ep 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" style="font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;">
<head>
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title></title>


<style type="text/css">
img {
max-width: 100%;
}
body {
-webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%; line-height: 1.6em;
}
body {
background-color: #f6f6f6;
}
@media only screen and (max-width: 640px) {
  body {
    padding: 0 !important;
  }
  h1 {
    font-weight: 800 !important; margin: 20px 0 5px !important;
  }
  h2 {
    font-weight: 800 !important; margin: 20px 0 5px !important;
  }
  h3 {
    font-weight: 800 !important; margin: 20px 0 5px !important;
  }
  h4 {
    font-weight: 800 !important; margin: 20px 0 5px !important;
  }
  h1 {
    font-size: 22px !important;
  }
  h2 {
    font-size: 18px !important;
  }
  h3 {
    font-size: 16px !important;
  }
  .container {
    padding: 0 !important; width: 100% !important;
  }
  .content {
    padding: 0 !important;
  }
  .content-wrap {
    padding: 10px !important;
  }
  .invoice {
    width: 100% !important;
  }
}
</style>
</head>

<body itemscope itemtype="http://schema.org/EmailMessage" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%; line-height: 1.6em; background-color: #f6f6f6; margin: 0;" bgcolor="#f6f6f6">

<table class="body-wrap" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; background-color: #f6f6f6; margin: 0;" bgcolor="#f6f6f6"><tr style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><td style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;" valign="top"></td>
                <td class="container" width="600" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; display: block !important; max-width: 600px !important; clear: both !important; margin: 0 auto;" valign="top">
                        <div class="content" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; max-width: 600px; display: block; margin: 0 auto; padding: 20px;">
                                <table class="main" width="100%" cellpadding="0" cellspacing="0" itemprop="action" itemscope itemtype="http://schema.org/ConfirmAction" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; border-radius: 3px; background-color: #fff; margin: 0; border: 1px solid #e9e9e9;" bgcolor="#fff"><tr style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><td class="content-wrap" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 20px;" valign="top">
                                                        <meta itemprop="name" content="Confirm Email" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;" /><table width="100%" cellpadding="0" cellspacing="0" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><tr style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><td class="content-block" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;" valign="top">
                                                                                Please confirm your email address by clicking the link below.
                                                                        </td>
                                                                </tr><tr style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><td class="content-block" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;" valign="top">
                                                                                We may need to send you critical information about our service and it is important that we have an accurate email address.
                                                                        </td>
                                                                </tr><tr style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><td class="content-block" itemprop="handler" itemscope itemtype="http://schema.org/HttpActionHandler" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;" valign="top">
                                                                                <a href="http://www.mailgun.com" class="btn-primary" itemprop="url" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; color: #FFF; text-decoration: none; line-height: 2em; font-weight: bold; text-align: center; cursor: pointer; display: inline-block; border-radius: 5px; text-transform: capitalize; background-color: #348eda; margin: 0; border-color: #348eda; border-style: solid; border-width: 10px 20px;">Confirm email address</a>
                                                                        </td>
                                                                </tr><tr style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><td class="content-block" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;" valign="top">
                                                                                &mdash; The Mailgunners
                                                                        </td>
                                                                </tr></table></td>
                                        </tr></table><div class="footer" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; clear: both; color: #999; margin: 0; padding: 20px;">
                                        <table width="100%" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><tr style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;"><td class="aligncenter content-block" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; vertical-align: top; color: #999; text-align: center; margin: 0; padding: 0 0 20px;" align="center" valign="top">Follow <a href="http://twitter.com/mail_gun" style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; color: #999; text-decoration: underline; margin: 0;">@Mail_Gun</a> on Twitter.</td>
                                                </tr></table></div></div>
                </td>
                <td style="font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;" valign="top"></td>
        </tr></table></body>
</html>
