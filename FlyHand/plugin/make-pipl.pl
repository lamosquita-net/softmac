#!/usr/bin/perl
# SPDX-License-Identifier: MPL-2.0
# Writes the PiPL resource of an Illustrator plug-in for macOS (Intel).
# Usage: make-pipl.pl NAME ENTRY_POINT OUTPUT
use strict;
use warnings;

my ($name, $entry, $out) = @ARGV;
die "usage: make-pipl.pl NAME ENTRY_POINT OUTPUT\n" unless $out;

sub padded { my $s = shift; $s .= "\0"; $s .= "\0" while length($s) % 4; return $s; }

my @props = (
  ['ivrs', pack('N', 2)],          # PiPL interface version
  ['kind', 'SPEA'],                # Suite PEA plug-in
  ['mi32', padded($entry)],        # Mach-O Intel entry point (the SDK writes the same key for 64-bit)
  ['pinm', padded($name)],         # plug-in name
);

my $data = pack('NNN', 1, 0, scalar @props);
for my $p (@props) {
  my ($key, $value) = @$p;
  $data .= 'ADBE' . $key . pack('NN', 0, length $value) . $value;
}
open my $fh, '>:raw', $out or die "$out: $!\n";
print $fh $data;
close $fh;
