# Copyright 2009, 2010 Kevin Ryde.

# This file is part of miscbits-el.
#
# miscbits-el is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# miscbits-el is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with miscbits-el; see the file COPYING.  Failing that, go to
# <http://www.gnu.org/licenses/>.


package MyUniqByInode;
use strict;
use warnings;

sub new {
  my ($class) = @_;
  return bless { seen => { },
               }, $class;
}

sub uniq {
  my ($self, $filename_or_handle) = @_;
  my ($dev, $ino)
    = (ref $filename_or_handle && $filename_or_handle->can('stat')
       ? $filename_or_handle->stat
       : stat ($filename_or_handle));
  if (! defined $dev) { return 1; } # error treated as unique

  my $key = "$dev,$ino";
  ### $key
  my $seen = $self->{'seen'};
  ### seen: exists $seen->{$key}
  return (! exists $seen->{$key}
          && ($seen->{$key} = 1));
}

# sub stat_dev_ino {
#   my ($filename) = @_;
#   my ($dev, $ino) = stat ($filename);
#   if (! defined $dev) {
#     # print "Cannot stat: $filename\n";
#     return '';
#   }
#   return "$dev,$ino";
# }

1;
__END__
