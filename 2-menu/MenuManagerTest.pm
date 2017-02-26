package MenuManagerTest;
use strict;
use warnings;
use uni::perl ':dumper';

use TestCase;
use base 'TestCase';

use MenuManager;


sub test_return_true_on_addmenu
{
    my ($self) = @_;
    my ($manager, $result, $expected_result);
    $manager         = $self->_buildMenuManager();
    $result          = $manager->addMenu("My menu", [{title => "Submenu", url => 'abc'}]);
    $expected_result = 1;

    $self->assert_num_equals($expected_result, $result);
}

sub test_return_complete_menu
{
    my ($self) = @_;
    my ($manager, $menu, $expected_menu);

    $manager       = $self->_buildMenuManager();
    $manager->addMenu("My menu", [{ title => "Submenu", url => 'abc' }]);
    $menu          = $manager->getMenu();
    $expected_menu = 
        [
            {
                title   => "My menu",
                url     => '',
                submenu => [
                    { title => "Submenu", url => 'abc' }
                ]
            }
        ];

    $self->assert_deep_equals($expected_menu, $menu);
}

sub test_add_menu_after
{
    my ($self) = @_;
    my ($manager, $menu, $expected_menu);

    $manager       = $self->_buildMenuManager();
    $manager->addMenu("My menu1", [{ title => "Submenu1", url => 'abc' }]);
    $manager->addMenu("My menu2", [{ title => "Submenu2", url => 'abc' }]);
    $manager->addMenuAfter("My menu1", "My menu3", [{ title => "Submenu3", url => 'abc' }]);
    $menu          = $manager->getMenu();
    $expected_menu =
        [
            {
                title => "My menu1",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc' }
                ]
            },
            {
                title => "My menu3",
                url => '',
                submenu => [
                    { title => "Submenu3", url => 'abc' }
                ]
            },
            {
                title => "My menu2",
                url => '',
                submenu => [
                    { title => "Submenu2", url => 'abc' }
                ]
            }
        ];


    $self->assert_deep_equals($expected_menu, $menu);
}

sub test_add_menu_before
{
    my ($self) = @_;
    my ($manager, $menu, $expected_menu);

    my $manager    = $self->_buildMenuManager();
    $manager->addMenu("My menu1", [{ title => "Submenu1", url => 'abc' }]);
    $manager->addMenu("My menu2", [{ title => "Submenu2", url => 'abc' }]);
    $manager->addMenuBefore("My menu1", "My menu3", [{ title => "Submenu3", url => 'abc' }]);
    $menu          = $manager->getMenu();
    $expected_menu =
        [
            {
                title => "My menu3",
                url => '',
                submenu => [
                    { title => "Submenu3", url => 'abc' }
                ]
            },
            {
                title => "My menu1",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc' }
                ]
            },
            {
                title => "My menu2",
                url => '',
                submenu => [
                    { title => "Submenu2", url => 'abc' }
                ]
            }
        ];

    $self->assert_deep_equals($expected_menu, $menu);
}

sub test_throw_on_unknown_anchor_for_addmenu
{
    my ($self) = @_;

    my $manager       = $self->_buildMenuManager();

    $self->assert_raises_matches(
        'Error::Simple',
        sub { $manager->addMenuBefore("Some unknown menu", "My menu3", [{ title => "Submenu3", url => 'abc' }]) },
        qr/Anchor menu not found/
    );
}

sub test_add_sub_menu_before
{
    my ($self) = @_;
    my ($manager, $menu, $expected_menu);

    $manager       = $self->_buildMenuManager();
    $manager->addMenu("My menu", [{ title => "Submenu1", url => 'abc1' }, { title => "Submenu2", url => 'abc2' }]);
    $manager->addSubmenuBefore("My menu", "Submenu2", { title => "Submenu3", url => 'abc3' });
    $menu          = $manager->getMenu();
    $expected_menu =
        [
            {
                title => "My menu",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc1' },
                    { title => "Submenu3", url => 'abc3' },
                    { title => "Submenu2", url => 'abc2' }
                ]
            }
        ];

    $self->assert_deep_equals($expected_menu, $menu);
}

sub test_add_sub_menu_after
{
    my ($self) = @_;
    my ($manager, $menu, $expected_menu);

    $manager       = $self->_buildMenuManager();
    $manager->addMenu("My menu", [{ title => "Submenu1", url => 'abc1' }, { title => "Submenu2", url => 'abc2' }]);
    $manager->addSubmenuAfter("My menu", "Submenu1", { title => "Submenu3", url => 'abc3' });
    $menu          = $manager->getMenu();
    $expected_menu =
        [
            {
                title => "My menu",
                url => '',
                submenu => [
                    { title => "Submenu1", url => 'abc1' },
                    { title => "Submenu3", url => 'abc3' },
                    { title => "Submenu2", url => 'abc2' }
                ]
            }
        ];

    $self->assert_deep_equals($expected_menu, $menu);
}

sub test_throw_on_unknown_anchor_for_addsubmenu
{
    my ($self) = @_;

    my $manager = $self->_buildMenuManager();

    $self->assert_raises_matches(
        'Error::Simple',
        sub { $manager->addSubmenuBefore("Some unknown menu", "Some unknown submenu", { title => "Submenu3", url => 'abc' }) },
        qr/Anchor menu not found/
    );
}

sub test_throw_on_unknown_subanchor_for_addsubmenu
{
    my ($self) = @_;

    my $manager = $self->_buildMenuManager();

    $manager->addMenu("My menu", [{ title => "Submenu1", url => 'abc1' }]);

    $self->assert_raises_matches(
        'Error::Simple',
        sub { $manager->addSubmenuBefore("My menu", "Some unknown submenu", { title => "Submenu3", url => 'abc' }) },
        qr/Anchor menu not found/
    );
}

sub _buildMenuManager
{
    my $self = shift;

    return MenuManager->new(@_);
}

1;
