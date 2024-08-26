package My::RuledPaper::Parse::Color;
use warnings;
use strict;

use base "Exporter";
our @EXPORT = qw();
our @EXPORT_OK = qw(parseColor);
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

use FindBin;
use lib "${FindBin::Bin}/../../../../lib";

use My::RuledPaper::Constants qw(:all);

our %COLORS;
BEGIN {
    %COLORS = (
        black          => COLOR_BLACK,
        white          => COLOR_WHITE,
        blue           => COLOR_BLUE,
        green          => COLOR_GREEN,
        red            => COLOR_RED,
        gray           => COLOR_GRAY,
        grey           => COLOR_GRAY,
        orange         => COLOR_ORANGE,
        magenta        => COLOR_MAGENTA,
        cyan           => COLOR_CYAN,
        yellow         => COLOR_YELLOW,
        black          => COLOR_BLACK,
        non_repro_blue => COLOR_NON_REPRO_BLUE,
    );
}

sub parseColor {
    my ($color) = @_;
    if ($color =~ m{^[[:xdigit:]]{3}$}) {
        my $r = hex(substr($color, 0, 1)) * 17;
        my $g = hex(substr($color, 1, 1)) * 17;
        my $b = hex(substr($color, 2, 1)) * 17;
        return [$r, $g, $b] if wantarray;
        return sprintf('#%02d%02d%02d', $r, $g, $b);
    }
    if ($color =~ m{^[[:xdigit:]]{6}$}) {
        my $r = hex(substr($color, 0, 2));
        my $g = hex(substr($color, 2, 2));
        my $b = hex(substr($color, 4, 2));
        return [$r, $g, $b] if wantarray;
        return sprintf('#%02d%02d%02d', $r, $g, $b);
    }
    if (exists $COLORS{lc($color)}) {
        return $COLORS{lc($color)};
    }
    return;
}

1;
