package My::Printable::Unit;
use warnings;
use strict;
use v5.10.0;

use lib "$ENV{HOME}/git/dse.d/perl-class-thingy/lib";
use Class::Thingy;
use Class::Thingy::RequireObject;

require_object;
public "units";
public "axis";

use Storable qw(dclone);

our $UNITS = {
    "pt" => {
        to_pt => 1,
        type => "imperial",
    },
    "pc" => {
        to_pt => 12,            # 1 pc = 12 pt
        type => "imperial",
    },
    "in" => {
        to_pt => 72,            # 1 in = 72 pt
        type => "imperial",
    },
    "cm" => {
        to_pt => (72 / 2.54),   # 1 cm ~= 28.3465 pt
        type => "metric",
    },
    "mm" => {
        to_pt => (72 / 25.4),   # 1 cm ~= 2.83465 pt
        type => "metric",
    },
    "px" => {
        to_pt => (72 / 96),     # 1 px = 0.75 pt
        type => "imperial"
    },
    "pd" => {                   # pixel dots
        to_pt => (72 / 300), # 1 pd = 1 dot on a 300dpi laser printer = 1/300 in = 72/300 pt
        type => "imperial"
    }
};

sub init {
    my ($self) = @_;
    $self->units(dclone($UNITS));
}

sub set_percentage_basis {
    goto &setPercentageBasis;
}
sub setPercentageBasis {
    my ($self, $value) = @_;
    delete $self->units->{'%'};
    my $hash = $self->add_unit('%', $value);
    $hash->{to_pt} /= 100;
}

sub add_unit {
    goto &addUnit;
}
sub addUnit {
    my ($self, $unit, $value, %options) = @_;
    die("Unit already defined: $unit\n") if exists $self->units->{$unit};
    my ($pt, $type) = $self->pt($value);

    my $aka = delete $options{aka};
    my @aka;
    if (defined $aka) {
        if (ref $aka eq "ARRAY") {
            @aka = @$aka;
        } elsif (ref $aka) {
            # do nothing
        } else {
            @aka = ($aka);
        }
    }
    foreach my $aka (@aka) {
        $self->units->{$aka} = $unit;
    }

    my $hash = {
        to_pt => $pt,
        type => $type,
        %options
    };
    return $self->units->{$unit} = $hash;
}

sub delete_unit {
    goto &deleteUnit;
}
sub deleteUnit {
    my ($self, $unit) = @_;
    delete $self->units->{$unit};
}

sub rx_units {
    my ($self) = @_;
    $self = REQUIRE_OBJECT($self);

    my @units = sort keys %{$self->units};
    @units = map {
        my $unit = $self->units->{$_};
        if (ref $unit eq "HASH" && $unit->{aka}) {
            if (ref $unit->{aka} eq "ARRAY") {
                ($_, @{$unit->{aka}});
            } elsif (ref $unit->{aka}) {
                ($_);
            } else {
                ($_, $unit->{aka});
            }
        } else {
            ($_);
        }
    } @units;
    my $units = join('|', map { quotemeta($_) } @units);
    return qr{$units}xi;
}

sub rx_number {
    my ($self) = @_;
    $self = REQUIRE_OBJECT($self);
    return qr{[\-\+]?\d+(?:\.\d*)?|\.\d+}ix;
}

sub pt {
    my ($self, $value) = @_;
    $self = REQUIRE_OBJECT($self);

    return undef if !defined $value;

    my ($numerator, $denominator);

    my $rx_units  = $self->rx_units;
    my $rx_number = $self->rx_number;
    my $spec;

    my $unit;
    if (ref $value eq "ARRAY") {
        ($value, $unit) = @$value;
    }

    if (defined $unit && $unit ne "") {
        $spec = "$value $unit";
        if ($value =~ m{\A
                        \s*
                        ($rx_number)
                        (?:
                            \s*
                            /
                            \s*
                            ($rx_number)
                        )?
                        \s*
                        \z}xi) {
            ($numerator, $denominator) = ($1, $2);
        } else {
            die("Invalid size specification: $value $unit\n");
        }
    } else {
        $spec = "$value";
        if ($value =~ m{\A
                        \s*
                        ($rx_number)
                        (?:
                            \s*
                            /
                            \s*
                            ($rx_number)
                        )?
                        \s*
                        ($rx_units)?
                        \s*
                        \z}xi) {
            ($numerator, $denominator, $unit) = ($1, $2, $3);
        } else {
            die("Invalid size specification: $spec\n");
        }
    }

    my $number;
    if (defined $denominator) {
        $number = $numerator / $denominator;
    } else {
        $number = $numerator;
    }

    if (!defined $unit || $unit eq "") {
        return ($number, "imperial") if wantarray;
        return $number;
    }

    my $unit_info = $self->units->{$unit};
    while (defined $unit_info && !ref $unit_info) {
        $unit_info = $self->units->{$unit_info};
    }
    if (!defined $unit_info) {
        die("Invalid size specification: $spec\n");
    }

    my $result_pt   = $number * $unit_info->{to_pt};
    my $result_type = $unit_info->{type};

    return ($result_pt, $result_type) if wantarray;
    return $result_pt;
}

1;