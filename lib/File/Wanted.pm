package File::Wanted;

use strict;
use warnings;

use parent qw(Exporter);
use File::Slurp qw(read_file);

our @EXPORT = qw(is_wanted);

sub is_wanted {
    my ($file, $checker) = @_;
    $checker //= \&is_hit;

    my $content = read_file($path);

    if (!defined $content) {
        warn "Failed to read $path: $!\n";
        return;
    }
    else {
        return is_hit($content);
    }
}

sub is_hit {
    my $content = shift;
    if ($content =~ m/\b__END__\b/) {
        return 1;
    }
    return 0;
}

1;

__END__
