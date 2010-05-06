package Moose::Meta::Method::Overridden;

use strict;
use warnings;

our $VERSION   = '1.03';
$VERSION = eval $VERSION;
our $AUTHORITY = 'cpan:STEVAN';

use base 'Moose::Meta::Method';

sub new {
    my ( $class, %args ) = @_;

    # the package can be overridden by roles
    # it is really more like body's compilation stash
    # this is where we need to override the definition of super() so that the
    # body of the code can call the right overridden version
    my $super_package = $args{package} || $args{class}->name;

    my $name = $args{name};

    my $super = $args{class}->find_next_method_by_name($name);

    (defined $super)
        || $class->throw_error("You cannot override '$name' because it has no super method", data => $name);

    my $super_body = $super->body;

    my $method = $args{method};

    my $body = sub {
        local $Moose::SUPER_PACKAGE = $super_package;
        local @Moose::SUPER_ARGS = @_;
        local $Moose::SUPER_BODY = $super_body;
        return $method->(@_);
    };

    # FIXME do we need this make sure this works for next::method?
    # subname "${super_package}::${name}", $method;

    # FIXME store additional attrs
    $class->wrap(
        $body,
        package_name => $args{class}->name,
        name         => $name
    );
}

1;

__END__

=pod

=head1 NAME

Moose::Meta::Method::Overridden - A Moose Method metaclass for overridden methods

=head1 DESCRIPTION

This class implements method overriding logic for the L<Moose>
C<override> keyword.

The overriding subroutine's parent will be invoked explicitly using
the C<super> keyword from the parent class's method definition.

=head1 METHODS

=over 4

=item B<< Moose::Meta::Method::Overridden->new(%options) >>

This constructs a new object. It accepts the following options:

=over 8

=item * class

The metaclass object for the class in which the override is being
declared. This option is required.

=item * name

The name of the method which we are overriding. This method must exist
in one of the class's superclasses. This option is required.

=item * method

The subroutine reference which implements the overriding. This option
is required.

=back

=back

=head1 BUGS

See L<Moose/BUGS> for details on reporting bugs.

=head1 AUTHOR

Yuval Kogman E<lt>nothingmuch@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2010 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
