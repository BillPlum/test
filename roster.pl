#!/usr/bin/perl

use warnings;
use strict;

use WWW::Mechanize;
use MIME::Lite;
use Term::ANSIColor;
my $agent = WWW::Mechanize->new();

$agent->get('http://wilson.excloud.com.au/Default');

$agent->field( 'email',    'weplumridge@gmail.com' );
$agent->field( 'password', 'wilson14969' );
$agent->submit();
$agent->get( 'http://wilson.excloud.com.au/rostersearch' );

my @a = split( /\n/, $agent->content );
my @light = ();
my @quick = ();
my @record = ();
my @report = ();
my $element_cnt = 0;
my $elements = {};
foreach my $line (@a) {
    $line =~ s/\s+/ /g;
    $line =~ s/(\n|\r|\x0d)//g;

    next if ( $line =~ m/href/ );
    
    if ( $line =~ m/<td>/ ) {
        $element_cnt++;
        $line =~ s/<td>//g; 
        $line =~ s/<\/td>//g;
        $line = dayWeek($line, \@record, \@quick, \@light) if ($element_cnt == 1); 
print $line ."\n";
        $elements->{$element_cnt} = $line;
    }   
    if ( $line =~ m/<\/tr>/ ) {
        push @report, $elements if ($elements);
        $elements = {};    # reset 
        $element_cnt = 0;
    }
    else {
        next;
    }   
}
use Data::Dumper;
use DateTime;
use Scalar::Util qw(looks_like_number);

print Dumper @report;
print color('bold blue');
print Dumper join ',',@light;
print color('reset');
#email(@report);
email(@light);
#email(join ',',@quick);
exit;

sub email {
    my $message = join ',',@_;
    
    my $to      = 'plu029@csiro.au';
    my $from    = 'bill_plumridge@netspace.net.au';
    my $cc      = 'weplumridge@gmail.com';
    my $subject = 'My Roster';
    my $msg = MIME::Lite->new(
                     From     => $from,
                     To       => $to,
                     Cc       => $cc,
                     Subject  => $subject,
                     Data     => $message
                     ) or die 'Cannot create MIME::Lite';
                     
    $msg->send or die 'Cannot send email';
    print "Email Sent Successfully\n";    
}

sub dayWeek {
    my ($line, $record, $quick, $light) = @_;

    my ($day,$month,$year) = split /\//, $line;
    use DateTime;
    return unless looks_like_number($month);

    my $dt = DateTime->new(year => int $year, month => int $month, day => int $day);

    push @{$record}, $dt->day_name if ( length $dt->day_name);
    push @{$quick},  $dt->day_name if (length $dt->day_name);
    push @{$light}, substr $dt->day_name,0,2 if (length $dt->day_name);
    return $dt->day_name;
}
