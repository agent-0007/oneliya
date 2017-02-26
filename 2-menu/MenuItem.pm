package MenuItem;
use strict;
use warnings;

sub new {

    my ($class, %params) = @_;

    my $self = {};
    $self->{title}   = $params{title}   if ($params{title});
    $self->{url}     = $params{url}     if ($params{url});
    $self->{submenu} = $params{submenu} if ($params{submenu});

    bless $self, $class;

    return $self;
}

sub title {
    my ($self, $params) = @_;
    $self->{title} = $params->{title} if defined $params->{title};
    return $self->{title};
}

sub url {
    my ($self, $params) = @_;
    $self->{url} = $params->{url} if defined $params->{url};
    return $self->{url};
}

sub submenu {
    my ($self, $params) = @_;
    $self->{submenu} = $params->{submenu} if defined $params->{submenu};
    return $self->{submenu};
}

sub DESTROY {
    my($self) = @_;
    undef($self->{title});
    undef($self->{url});
    undef($self->{submenu});
}

1;