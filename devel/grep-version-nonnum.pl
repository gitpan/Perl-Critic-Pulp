#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Perl-Critic-Pulp.
#
# Perl-Critic-Pulp is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Perl-Critic-Pulp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Perl-Critic-Pulp.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Perl6::Slurp;

use lib::abs '.';
use MyLocatePerl;
use MyStuff;
use Text::Tabs ();

my $verbose = 0;

my $l = MyLocatePerl->new (regexp => qr/\.pm$/);
while (my ($filename, $str) = $l->next) {
  if ($verbose) { print "look at $filename\n"; }

  $str =~ s/^[ \t]*#.*$//mg;

  pos($str) = 0;
  # $str =~ /\$VERSION\s*=\s*
  #          ('[^']*?[^'0-9.]
  #          |"[^"]*?[^"0-9.]
  #          |q\([^)]*?[^)0-9.]
  #          |q\{[^}]*?[^}0-9.]
  #
  #            # qw$...$ ok
  #            # qv() version module ok
  #          |q[^vw({]
  #          )
  #         /gx
  #           or next;
  # my $pos = pos($str);
  # my ($line, $col) = MyStuff::pos_to_line_and_column ($str, $pos);
  # print "$filename:$line:$col: non-numeric VERSION string\n",
  #   MyStuff::line_at_pos($str,$pos);

  $str =~ /[^A-Za-z_]VERSION\s+(>[^>]|<|[!=]=)/g
    or next;
  my $pos = pos($str);
  my ($line, $col) = MyStuff::pos_to_line_and_column ($str, $pos);
  print "$filename:$line:$col: explicit VERSION compare\n",
    MyStuff::line_at_pos($str,$pos);
}

exit 0;