package Traversal::Recursive::Davido;

use strict;
use warnings;

use File::Spec::Functions;
use File::Slurp;
use List::Util qw(max);

sub filetype {
    my $path = shift;
    my @s = lstat $path;

    return { } if !@s && $! eq 'No such file or directory';
    my %d
    $d{'type'} = -f _ ? 'file'  :
                 -d _ ? 'dir'   :
                 -p _ ? 'pipe'  :
                        'other' ;

    $d{'symlink_target'} = eval {readlink($path)} || "0E0" if -l;
    return \%d;
}

sub traverse {
    my ($path, $trigger, $action, $cur_depth, $max_depth) = @_;

    $cur_depth   //= 0;
    ${$max_depth //= \(my $value)} //= 0;
    my $ftype    = filetype($path)->{'type'};

    if ($ftype eq 'dir') {
        opendir my $dh, $path or die "Unable to opendir $path: $!\n";
        while (my $entity = readdir($dh)) {
            next if $entity =~ m/^\.{1,2}$/;
            traverse(
                catfile($path, $entity),
                $trigger,
                $action,
                $cur_depth+1,
                $max_depth
            );
        }
    }
    elsif ($ftype eq 'file') {
        if ($trigger->($path)) {
            $$max_depth = max($$max_depth, $cur_depth);
            $action->($path, $cur_depth);
        }
    }
    else {
        warn "Unable to process filetype '$ftype' at $path.\n";
    }
    return $$max_depth;
}

