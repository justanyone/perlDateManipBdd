# Original research-only debugger hook. It records call names, never source text.
package DB;
BEGIN { *DB::DB = sub { }; }
use strict;
use warnings;
our $sub;
our %date_manip_calls;
sub sub {
    ++$date_manip_calls{$sub} if !ref($sub) && $sub =~ /^Date::Manip(?:::|$)/;
    no strict 'refs';
    goto &$sub;
}
END {
    if (defined $ENV{DATEMANIP_TRACE_FILE}) {
        local $^P = 0;
        require JSON::PP;
        open my $fh, '>', $ENV{DATEMANIP_TRACE_FILE} or die "cannot write call trace: $!";
        print {$fh} JSON::PP->new->canonical->encode({calls => \%date_manip_calls}), "\n";
        close $fh or die "cannot close call trace: $!";
    }
}
1;
