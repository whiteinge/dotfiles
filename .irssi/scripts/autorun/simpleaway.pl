#!/usr/bin/perl
# by Seth House <seth@eseth.com>
# Based on `anotheraway.pl` by Stefan Tomanek <stefan@pico.ruhr.de>

# If no keys are pressed for (default) one hour this script will set your away
# status. The timer resets when you clear your away status. Simple.

use strict;
use vars qw($VERSION %IRSSI);
$VERSION = "20090215";
%IRSSI = (
    authors     => "Seth House",
    contact     => "seth\@eseth.com",
    name        => "simpleaway",
    description => "A featureless autoaway timer.",
    license     => "GPLv2",
    changed     => "$VERSION",
);
use Irssi 20020324;
use vars qw($timer @signals);

@signals = ('gui key pressed');

sub set_away {
    Irssi::timeout_remove($timer);
    my $message = Irssi::settings_get_str("simpleaway_message");
    my @servers = Irssi::servers();
    return unless @servers;
    Irssi::signal_remove($_, "reset_timer") foreach (@signals);
    $servers[0]->command('AWAY '.$message);
    Irssi::signal_add($_, "start_timer") foreach (('away mode changed'));
}

sub start_timer {
    Irssi::signal_add($_, "reset_timer") foreach (@signals);
    reset_timer();
}

sub reset_timer {
    Irssi::timeout_remove($timer);
    my $timeout = Irssi::settings_get_int("simpleaway_timeout");
    $timer = Irssi::timeout_add($timeout * 1000, "set_away", undef);
}

Irssi::settings_add_str($IRSSI{name}, 'simpleaway_message', 'afk');
Irssi::settings_add_int($IRSSI{name}, 'simpleaway_timeout', 3600);

{
    start_timer();
}

print CLIENTCRAP '%B>>%n '.$IRSSI{name}.' '.$VERSION.' loaded';
