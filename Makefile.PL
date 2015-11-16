#!/usr/bin/env perl
use ExtUtils::MakeMaker;
use strict;
use warnings;





WriteMakefile(
  NAME         => 'my_ibdb.pl',
  VERSION      => '1.0',
  AUTHOR       => 'Henk van Tijen <henkvantijen@gmail.com>',
  EXE_FILES    => ['app.pl'],
  PREREQ_PM    => {'Mojolicious' => '6.0'},
  #test         => {TESTS => 't/*.t'}
);

  
