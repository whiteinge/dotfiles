#!/usr/bin/perl
# by Seth House <seth@eseth.com>
# Based on `anotheraway.pl` by Stefan Tomanek <stefan@pico.ruhr.de>

# If no keys are pressed for (default) one hour this script will set your away
# status. The timer resets when you clear your away status. Simple.

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = "0.01";
%IRSSI = (
    authors     => "Seth House",
    contact     => "seth\@eseth.com",
    name        => "simpleaway",
    description => "A featureless autoaway timer.",
    license     => "GPLv2",
    changed     => "20090216",
);

use vars qw($timer $signal);

sub set_away {
    Irssi::signal_remove($signal, "reset_timer");
    Irssi::timeout_remove($timer);
    my $message = Irssi::settings_get_str("simpleaway_message");
    my @servers = Irssi::servers();
    return unless @servers;
    $servers[0]->command('AWAY '.$message);
    Irssi::signal_add('notifylist away changed', "start_timer");
}

sub start_timer {
    $signal = Irssi::signal_add('gui key pressed', "reset_timer");
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
