use Test::More tests => 3;
use strict;
use warnings;

my $class = 'MyIMDB::Models::Base';

# Testing require
require_ok $class;

# Testing use
use_ok $class;

# Testing constructor
my $obj = $class->new();
isa_ok $obj, $class;
