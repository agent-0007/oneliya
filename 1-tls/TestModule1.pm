package TestModule1;
use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;


sub connect
{
    my $class = shift;
    my ($url) = @_;

    my $ua = LWP::UserAgent->new();

    my $request = HTTP::Request->new(GET => $url);
    my $response = $ua->request($request);

    return $response->status_line() . "\n";
}

1;
