#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use File::Slurp qw(read_file);
use File::Spec::Functions qw(catfile);

sub is_hit {
    my $content = shift;
    if ($content =~ m/\b__END__\b/) {
        return 1;
    }
    return 0;
}

our @hit_info;
sub hit_action {
    my ($path, $depth) = @_;
    push @hit_info, [$path, $depth];
}

sub filetype {
    my $path = shift;
    my @s = lstat $path;
    if(! @s) {
        return { } if $! eq 'No such file or directory';
    }
    my %d;
    $d{'type'} = -f _ ? 'file'    :
                 -d _ ? 'dir'     :
                 -p _ ? 'pipe'    :
                        'other'   ;

    $d{'symlink_target'}   = eval {readlink($path)} || "0E0" if -l _;
    return \%d;
}

sub traverse {
    my ($path, $trigger, $action, $cur_depth, $max_depth) = @_;

    $cur_depth //= 0;

    ${$max_depth //= \(my $value)} //= 0;

    my $ftype = filetype($path)->{'type'};

    if ($ftype eq 'dir') {
        opendir my $dh, $path or die "Unable to opendir $path: $!\n";
        while (my $entity = readdir($dh)) {
            next if $entity =~ m/^\.{1,2}$/;
            traverse(catfile($path,$entity), $trigger, $action, $cur_depth+1, $max_depth);
        }
    }
    elsif ($ftype eq 'file') {
        my $c = read_file($path);
        if ($trigger->($c)) {
            $$max_depth = $cur_depth > $$max_depth ? $cur_depth : $$max_depth;
            $action->($path, $cur_depth);
        }
    }
    else {
        warn "Unable to process filetype '$ftype' at $path.\n";
    }
    return $$max_depth;
}

@hit_info = ();
my $d = traverse($ARGV[0] // '/home/doswald/scripts/alt', \&is_hit, \&hit_action);

is_deeply \@hit_info, [
    ['/home/doswald/scripts/alt/lib/Foo/Bar.pm', 3],
    ['/home/doswald/scripts/alt/lib/Foo/Baz/Bump.pm', 4],
    ['/home/doswald/scripts/alt/lib/Ping.pm', 2],
], 'Found correct hits at correct depth.';

is $d, 4, 'Correct max_depth reported.';

done_testing();
