package Imager::Simple;

use warnings;
use strict;

use base 'Class::Accessor::Fast';

use Carp 'croak';
use Scalar::Util 'blessed';

use Imager;

__PACKAGE__->mk_accessors(qw(frames format));

=head1 NAME

Imager::Simple - Make common Imager use cases easy

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

C<Imager::Simple> makes common uses cases with L<Imager|Imager> easy.

  use Imager::Simple;

  # scale image "anim.gif" and assign output to a variable
  $scaled_data = eval {
    Imager::Simple->read('anim.gif')->scale(100, 100, 'min')->data;
  };
  if ($@) {
    die "error from Imager::Simple: $@";
  }

=head1 METHODS

=head2 read

  $img = Imager::Simple->read($source, $type);

=cut

sub read {
    my ($self, $d, $type) = @_;
    my @args;
    my $ref = ref $d;

    $self = bless {}, $self unless ref $self;
    if ($ref) {
	# read through supplied code
	if ($ref eq 'CODE') {
	    @args = (callback => $d);
	}
	# get data from a filehandle
	elsif ($ref eq 'GLOB' or blessed($d) and $d->can('read')) {
	    @args = (fh => $d);
	}
	# read from scalar
	elsif ($ref eq 'SCALAR') {
	    @args = (data => $$d);
	}
    }
    else {
	@args = (file => $d);
    }
    push @args, 'type', $type if defined $type;
    @{$self->{frames}} = Imager->read_multi(@args)
	or croak Imager->errstr;

    $self->{format} = $self->{frames}->[0]->tags(name => 'i_format');

    $self;
}

=head2 format

  $img->format('gif');

Set output format for the image.

=head2 clone

TODO

=cut

sub clone {
    croak "not implemented yet";
}

=head2 scale

  $scaled_img = $img->scale(100);
  $scaled_img = $img->scale({y => 100});
  $scaled_img = $img->scale(100, 100, 'min');
  $scaled_img = $img->scale(100, 100, {type => 'min'});
  $scaled_img = $img->scale('min', {height => 100, width => 100});

Scale the image in place.

Accepts absolute and named arguments. Named arguments must be supplied
a hash reference as last argument. The order of absolute argument
positions is C<width>, C<height>, C<type>. All other arguments can only
be supplied as named arguments.
Possible names for the image width are C<width>, C<x> and C<xpixels> -
names for the image height are C<height>, C<y> and C<ypixels> - and
finally the type must be named C<type>. For all other known named
arguments see L<Imager::Transformations|Imager::Transformations/scale>.

Absolute and named arguments can be mixed, whereas absolute arguments
supersede named ones.

Image tags are copied from the old image(s) where applicable.

=cut

sub scale {
    my $self = shift;
    my $opt = ref $_[-1] eq 'HASH' ? pop : {};
    my (@args, @out, $out, $tag, $t);

    for (shift, $opt->{x}, $opt->{xpixels}, $opt->{width}) {
	push(@args, xpixels => $_), last if defined;
    }
    for (shift, $opt->{y}, $opt->{ypixels}, $opt->{height}) {
	push(@args, ypixels => $_), last if defined;
    }
    for (shift, $opt->{type}) {
	push(@args, type =>  $_), last if defined;
    }
    for (qw(constrain scalefactor xscalefactor yscalefactor qtype)) {
	push @args, $_, $t if defined($t = $opt->{$_});
    }
    for my $frame (@{$self->{frames}}) {
	$out = $frame->scale(@args)
	    or croak $frame->errstr;
	for $tag (qw(i_format i_xres i_yres i_aspect_only
	    gif_background gif_trans_index gif_trans_color gif_delay gif_loop
	)) {
	    $out->deltag(name => $tag);
	    $out->addtag(name => $tag, value => $_)
		for $frame->tags(name => $tag);
	}
	push @out, $out;
    }
    $self->{frames} = \@out;

    $self;
}

=head2 write

  $img->write($destination);

Write image data to given destination.

C<$destination> can be:

=over 4

=item A scalar

is taken as a filename.

=item File handle or L<IO::Handle|IO::Handle> object

that must be opened in write mode and should be set to C<binmode>.

=item A scalar reference

points to a buffer where the image data has to be stored.

=item A code reference

to do the writing.

=item Avoided

in what case write acts like L<the data() method|/data> by returning
the image buffer.

=back

=cut

sub write {
    my ($self, $d) = @_;

    return $self->data unless defined $d;	# for convenience
    my $key;
    my $ref = ref $d;

    if ($ref) {
	# read through supplied code
	if ($ref eq 'CODE') {
	    $key = 'callback';
	}
	# get data from a filehandle
	elsif ($ref eq 'GLOB' or blessed($d) and $d->can('read')) {
	    $key = 'fh';
	}
	# read from scalar
	elsif ($ref eq 'SCALAR') {
	    $key = 'data';
	}
    }
    else {
	$key = 'file';
    }

    Imager->write_multi({$key => $d, type => $self->format}, @{$self->frames})
	or croak Imager->errstr;

    $self;
}

=head2 data

=cut

sub data {
    my $self = shift;
    my $data;
    
    Imager->write_multi({data => \$data, type => $self->format}, @{$self->frames})
	or croak Imager->errstr;

    $data;
}

1;

__END__

=head1 AUTHOR

Bernhard Graf, C<< <graf at movingtarget.de> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-imager-simple at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Imager-Simple>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Imager::Simple

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Imager-Simple>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Imager-Simple>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Imager-Simple>

=item * Search CPAN

L<http://search.cpan.org/dist/Imager-Simple>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Bernhard Graf, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

