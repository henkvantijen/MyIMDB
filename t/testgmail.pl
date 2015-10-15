use strict;
   use warnings;

   use Email::Send::SMTP::Gmail;

   my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',
                                           -login=>'henkvantijen@gmail.com',
                                           -pass=>'gm31l1963');

   $mail->send(-to=>'henkvantijen+test@gmail.com', -subject=>'Hello!', -body=>'Just testing it');

#, -attachments=>'full_path_to_file');

   $mail->bye;
