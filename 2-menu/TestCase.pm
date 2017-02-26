package TestCase;
use strict;
use warnings;
use base 'Test::Unit::TestCase';

sub assert_raises_matches
{
    my $self = shift;
    my ($error_class, $cb, $re, $diag) = @_;

    my $error = $self->assert_raises($error_class => sub { $cb->() }, $diag);
    $self->assert_matches($re, "$error");
}

1;
