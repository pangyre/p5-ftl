#!/usr/bin/env perl
use strict;
use warnings;
use FTL;

FTL->setup_engine('PSGI');
my $app = sub { FTL->run(@_) };

