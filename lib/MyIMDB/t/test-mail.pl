 use strict;
  use Email::Sender::Simple qw(sendmail);
  use Email::Simple;
  use Email::Simple::Creator;

  my $email = Email::Simple->create(
    header => [
      To      => 'henkvantijen+simple@gmail.com',
      From    => 'henkvantijen@gmail.com',
      Subject => "don't forget to *enjoy the sauce*",
    ],
    body => "This message is short, but at least it's cheap.\n",
  );

  sendmail($email) or die $!;
