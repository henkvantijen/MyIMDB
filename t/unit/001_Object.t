use Test::More;

use strict;
use warnings;

my $class = 'MyIMDB::Models::Object';

# Testing require
require_ok $class;

# Testing use 
use_ok $class;

# Testing class name
my $model_object = $class->new();
isa_ok $model_object, $class;

my $val = $model_object->init_db;

note explain $val;

done_testing();

