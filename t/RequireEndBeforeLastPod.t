#!/usr/bin/perl

# Copyright 2008, 2009 Kevin Ryde

# This file is part of Perl-Critic-Pulp.
#
# Perl-Critic-Pulp is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Perl-Critic-Pulp is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Perl-Critic-Pulp.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use Perl::Critic::Policy::Documentation::RequireEndBeforeLastPod;
use Test::More tests => 22;

SKIP: { eval 'use Test::NoWarnings; 1'
          or skip 'Test::NoWarnings not available', 1; }


#-----------------------------------------------------------------------------
my $want_version = 20;
cmp_ok ($Perl::Critic::Policy::Documentation::RequireEndBeforeLastPod::VERSION,
        '>=', $want_version, 'VERSION variable');
cmp_ok (Perl::Critic::Policy::Documentation::RequireEndBeforeLastPod->VERSION,
        '>=', $want_version, 'VERSION class method');
{
  ok (eval { Perl::Critic::Policy::Documentation::RequireEndBeforeLastPod->VERSION($want_version); 1 }, "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Perl::Critic::Policy::Documentation::RequireEndBeforeLastPod->VERSION($check_version); 1 }, "VERSION class check $check_version");
}


#-----------------------------------------------------------------------------
require Perl::Critic;
my $critic = Perl::Critic->new
  ('-profile' => '',
   '-single-policy' => 'Documentation::RequireEndBeforeLastPod');
{ my @p = $critic->policies;
  is (scalar @p, 1,
      'single policy RequireEndBeforeLastPod');

  my $policy = $p[0];
  ok (eval { $policy->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { $policy->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

# ^Z is equivalent to __END__, but don't exercise that because PPI 1.204
# doesn't support it
#
foreach my $data (## no critic (RequireInterpolationOfMetachars)

                  # from the POD, ok
                  [ 0, '
program_code();

1;
__END__

=head1 NAME
...' ],

#---------------------------------
                  # from the POD, bad
                  [ 1, '
program_code();
1;

=head1 NAME
...
' ],

#---------------------------------
                  [ 0, '1;' ],
                  [ 0, '__END__' ],
                  # note PPI doesn't like a completely empty '' until 1.204_01
                  [ 0, ' ' ],

#---------------------------------
# end with code
                  [ 0, '
=head2 Foo

=cut

1;' ],

#---------------------------------
# end with pod
                  [ 1, '
1;

=head2 Foo
' ],


#---------------------------------
# with an __END__
                  [ 0, '
__END__

# comment

=head2 Foo
' ],

#---------------------------------
# with an __END__ and comment
                  [ 0, '
__END__

=head2 Foo

=cut

# comment
' ],

#---------------------------------
# end with comments
                  [ 0, '
=head2 Foo

=cut

# comment1

# comment2
' ],

#---------------------------------
# no code, but some comments
                  [ 0, '
=head2 Foo

=cut

# comment

=head2 Bar

=cut
' ],

#---------------------------------
# bad, with a final comments
                  [ 1, '
code;

=head2 Foo

=cut

# comment
' ],

#---------------------------------
# bad, with a comment in between
                  [ 1, '
code;
# comment

=head2 Foo

=cut
' ],

#---------------------------------
# with __DATA__ instead is ok
                  [ 0, '
code;

=head2 Foo

=cut

__DATA__
something
' ],

#---------------------------------
                  ## use critic
                 ) {
  my ($want_count, $str) = @$data;

  my @violations = $critic->critique (\$str);
  foreach (@violations) {
    diag ($_->description);
  }
  my $got_count = scalar @violations;
  is ($got_count, $want_count, "str: $str");
}

exit 0;
