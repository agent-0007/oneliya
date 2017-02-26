package MenuManager;
use strict;
use warnings;
use Carp;
use uni::perl ':dumper';

use MenuItem;

sub new
{
    my ($class, %config) = @_;

    my $self = {};
    $self->{menu} = [];
    bless $self, $class;

    return $self;
}

sub menu {
    my ($self, $params) = @_;
    $self->{menu} = $params->{menu} if defined $params->{menu};
    return $self->{menu};
}


sub _paramsToMenu
{
    my ($self, @menu) = @_;
    my %params;
    ($params{title}, $params{submenu}) = splice @menu, 0, 2;
    if ($params{submenu}) {
        my @new_submenu;
        foreach my $submenu (@{$params{submenu}}) {
            my $item = MenuItem->new(%{$submenu});
            push @new_submenu, $item;
        }
        $params{submenu} = \@new_submenu;
    }

    return \%params;
}

sub addMenu
{
    my ($self, @menu) = @_;
    croak 'add() requires title and submenu pairs' unless @menu % 2 == 0;
    my $m = $self->menu;
    my $params = $self->_paramsToMenu(@menu);
    my $item = MenuItem->new(%{$params});
    push @{$m}, $item;        
    $self->menu({menu => $m});

    return 1;
}

sub addMenuAfter
{
    my ($self, $anchor, @menu) = @_;
    my $params = $self->_paramsToMenu(@menu);
    my $menu_for_add = MenuItem->new(%{$params});
    $params = {
        type         => 'after',
        anchor       => $anchor,
        subanchor    => undef,
        menu_for_add => $menu_for_add,
        menu         => $self->menu
    };

    $self->menu({menu => $self->_addMenuInPosition($params)});

    return 1;
}

# этот метод надо объеденять с предыдущим, но тогда все втесте поотваливатеся(
# не знаю кто так модно стал передавать массив в аргументы, но это прям адок
sub addMenuBefore
{
    my ($self, $anchor, @menu) = @_;

    my $params       = $self->_paramsToMenu(@menu);
    my $menu_for_add = MenuItem->new(%{$params});
    $params = {
        type         => 'before',
        anchor       => $anchor,
        subanchor    => undef,
        menu_for_add => $menu_for_add,
        menu         => $self->menu
    };

    $self->menu({menu => $self->_addMenuInPosition($params)});

    return 1;
}

sub _addMenuInPosition
{
    my ($self, $params) = @_;

    my @new;
    my $added = 0;
    my $found_subanchor = 1;
    foreach my $menu_item ( @{$params->{menu}} ) {
        if ($params->{type} eq 'after' && $menu_item->title eq $params->{anchor}) {
            push @new, $menu_item;
            push @new, $params->{menu_for_add};
            $added++;
        } elsif ($params->{type} eq 'before' && $menu_item->title eq $params->{anchor}) {
            push @new, $params->{menu_for_add};
            push @new, $menu_item;
            $added++;
        } else {
            push @new, $menu_item;
        }
    }
    Carp::croak("Anchor menu not found") unless $added;
    
    return \@new;
}

# надо тут все переделывать, адовый интерфейс.
# надо объеденять addMenuBefore, addMenuAfter, addSubmenuBefore, addSubmenuAfter в одну
# без изменения в тесте это сделать не получится, тест взорвется
sub addSubmenuBefore
{
    my ($self, $anchor, $subanchor, @menu) = @_;
    foreach my $params (@menu) {
        my $menu_for_add = MenuItem->new(%{$params});
        $params = {
            type         => 'before',
            anchor       => $anchor,
            subanchor    => $subanchor,
            menu_for_add => $menu_for_add,
            menu         => $self->menu
        };

        $self->menu({menu => $self->_addSubmenuInPosition($params)});
    }

    return 1;
}

# надо тут все переделывать, адовый интерфейс.
# надо объеденять addMenuBefore, addMenuAfter, addSubmenuBefore, addSubmenuAfter в одну
sub addSubmenuAfter
{
    my ($self, $anchor, $subanchor, @menu) = @_;
    foreach my $params (@menu) {
        my $menu_for_add = MenuItem->new(%{$params});
        $params = {
            type         => 'after',
            anchor       => $anchor,
            subanchor    => $subanchor,
            menu_for_add => $menu_for_add,
            menu         => $self->menu
        };

        $self->menu({menu => $self->_addSubmenuInPosition($params)});
    }

    return 1;
}

sub _addSubmenuInPosition
{
    my ($self, $params) = @_;
    my $found_anchor = 0;
    my @new;
    my $found_anchor = 0;
    foreach my $menu_item ( @{$params->{menu}} ) {
        if ($menu_item->title eq $params->{anchor}) {
            $found_anchor = 1;
            my $submenu = $menu_item->submenu;
            my $params = {
                type         => $params->{type},
                anchor       => $params->{subanchor},
                menu_for_add => $params->{menu_for_add},
                menu         => $menu_item->submenu
            };
            $menu_item->submenu({'submenu' => $self->_addMenuInPosition($params)});
        }
        push @new, $menu_item;
    }
    Carp::croak("Anchor menu not found") unless $found_anchor;

    return \@new;
}

sub getMenu
{
    my ($self, $params) = @_;
    my ($menu, $menu_items);

    if ($params->{recursion_counter} > 50) {
       croak 'too deep recursion!';
    }

    $menu_items = $params->{menu_items} || $self->{menu};
    foreach my $menu_item ( @{$menu_items} ) {

        my $menu_fields = { 
            title   => $menu_item->title,
            url     => $menu_item->url || '',
        };

        if ($menu_item->submenu) {
            $menu_fields->{submenu} = $self->getMenu({menu_items => $menu_item->submenu, $params->{recursion_counter}+1})
        }

        push @{$menu}, $menu_fields;
    }

    return $menu;
}

sub DESTROY {
    my($self) = @_;
    undef($self->{menu});
}

1;
