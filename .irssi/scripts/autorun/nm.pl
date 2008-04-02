use Irssi;
use strict;

use vars qw($VERSION %IRSSI);

$VERSION="0.3.0";
%IRSSI = (
    authors=> 'BC-bd',
    contact=> 'bd@bc-bd.org',
    name=> 'nm',
    description=> 'right aligned nicks depending on longest nick',
    license=> 'GPL v2',
    url=> 'https://bc-bd.org/svn/repos/irssi/trunk/',
);

# nm.pl
# for irssi 0.8.4 by bd@bc-bd.org
#
# right aligned nicks depending on longest nick
#
# Here is a script written in perl for irssi. This script takes the name in the
# channel and colors the name and sets them in place on the screen. Copy this
# script to a text editor an save as nm.pl. Run in terminal "mkdir
# ~/.irssi/scripts/"   now take the nm.pl file and place it is the new file
# created. Now open irssi and connect to the server and your channel of choice
# than type "/script load nm.pl"  than type "/set neat_colorize on" to activate
# the script. When the script is running in irssi you should see all the names
# lined up neatly and colorized for convience.
# 
# inspired by neatmsg.pl from kodgehopper
# formats taken from www.irssi.de
# thanks to adrianel for some hints
# inspired by nickcolor.pl by Timo Sirainen and Ian Peters
#
#########
# USAGE
###
#
# /neatredo to recalculate longest nick. (should not be needed)
#
#########
# OPTIONS
#########
#
# /set neat_colorize
#     * ON  : colorize nicks
#     * OFF : do not colorize nicks
#
# /set neat_colors
#     Use these colors when colorizing nicks, eg:
#
#         /set neat_colors yYrR
#
#     See the file formats.txt on an explanation of what colors are
#     available.
#
# /set neat_right_mode
#    * ON  : print the mode of the nick e.g @%+ after the nick
#    * OFF : print it left of the nick
#
# /set neat_maxlength
#    * number : Maximum length of Nicks to display. Longer nicks are truncated.
#    * 0      : Do not truncate nicks.
#
###
################
###
#
# Changelog
#
# Version 0.3.0
#  - integrate nick coloring support
#
# Version 0.2.1
#  - moved neat_maxlength check to reformat() (thx to Jerome De Greef )
#
# Version 0.2.0
#  - by adrianel
#     * reformat after setup reload
#     * maximum length of nicks
#
# Version 0.1.0
#  - got lost somewhere
#
# Version 0.0.2
#  - ugly typo fixed
#
# Version 0.0.1
#  - initial release
#
###
################
###
#
# BUGS
#
# Well its a feature: due to the lacking support of extendable themes
# from irssi it is not possible to just change some formats per window.
# This means that right now all windows are aligned with the same nick
# length which can be somewhat annoying.
# If irssi supports extendable themes i will include per server indenting
# and a setting where you can specify servers you don't want to be indented
#
###
################

my ($longestNick, %saved_colors, @colors, $alignment);

my $colorize = -1;

sub reformat() {
    my $max = Irssi::settings_get_int('neat_maxlength');

    if ($max && $max < $longestNick) {
        $longestNick = $max;
    }

    if (Irssi::settings_get_bool('neat_right_mode') == 0) {
        Irssi::command('^format own_msg {ownmsgnick $2 {ownnick $[-'.$longestNick.']0}}$1');
        Irssi::command('^format own_msg_channel {ownmsgnick $3 {ownnick $[-'.$longestNick.']0}{msgchannel $1}}$2');
        Irssi::command('^format pubmsg_me {pubmsgmenick $2 {menick $[-'.$longestNick.']0}}$1');
        Irssi::command('^format pubmsg_me_channel {pubmsgmenick $3 {menick $[-'.$longestNick.']0}{msgchannel $1}}$2');
        Irssi::command('^format pubmsg_hilight {pubmsghinick $0 $3 $[-'.$longestNick.']1%n}$2');
        Irssi::command('^format pubmsg_hilight_channel {pubmsghinick $0 $4 $[-'.$longestNick.']1{msgchannel $2}}$3');
    } else {
        Irssi::command('^format own_msg {ownmsgnick {ownnick $[-'.$longestNick.']0$2}}$1');
        Irssi::command('^format own_msg_channel {ownmsgnick {ownnick $[-'.$longestNick.']0$3}{msgchannel $1}}$2');
        Irssi::command('^format pubmsg_me {pubmsgmenick {menick $[-'.$longestNick.']0}$2}$1');
        Irssi::command('^format pubmsg_me_channel {pubmsgmenick {menick $[-'.$longestNick.']0$3}{msgchannel $1}}$2');
        Irssi::command('^format pubmsg_hilight {pubmsghinick $0 $0 $[-'.$longestNick.']1$3%n}$2');
        Irssi::command('^format pubmsg_hilight_channel {pubmsghinick $0 $[-'.$longestNick.']1$4{msgchannel $2}}$3');
    }
};

sub cmd_neatRedo{
    $longestNick = 0;

    # get own nick length
    foreach (Irssi::servers()) {
        my $len = length($_->{nick});

        if ($len > $longestNick) {
            $longestNick = $len;
        }
    }

    # get the lengths of the other people
    foreach (Irssi::channels()) {
        foreach ($_->nicks()) {
            $saved_colors{$_->{nick}} = "%".nick_to_color($_->{nick});

            my $len = length($_->{nick});

            if ($len > $longestNick) {
                $longestNick = $len;
            }
        }
    }

    reformat();
}

sub sig_newNick
{
    my ($channel, $nick) = @_;

    my $thisLen = length($nick->{nick});

    if ($thisLen > $longestNick) {
        $longestNick = $thisLen;
        reformat();
    }

    $saved_colors{$nick->{nick}} = "%".nick_to_color($nick->{nick});
}

# something changed
sub sig_changeNick
{
    my ($channel, $nick, $old_nick) = @_;

    # we only need to recalculate, if this was the longest nick
    if (length($old_nick) == $longestNick) {
  
        my $thisLen = length($nick->{nick});

        # and only if the new nick is shorter
        if ($thisLen > $longestNick) {
            $longestNick = $thisLen;
            reformat();
        } else {
            cmd_neatRedo();
        }
    }

    $saved_colors{$nick->{nick}} = $saved_colors{$nick->{old_nick}};
    delete $saved_colors{$nick->{old_nick}}
}
sub sig_removeNick
{
    my ($channel, $nick) = @_;

    my $thisLen = length($nick->{nick});

    # we only need to recalculate, if this was the longest nick
    if ($thisLen == $longestNick) {
        cmd_neatRedo();
    }
}

# based on simple_hash from nickcolor.pl
sub nick_to_color($) {
    my ($string) = @_;
    chomp $string;
    my @chars = split //, $string;
    my $counter;

    foreach my $char (@chars) {
        $counter += ord $char;
    }

    return $colors[$counter % $#colors];
}

sub color_left($) {
    Irssi::command('^format pubmsg {pubmsgnick $2 {pubnick '.$_[0].'$[-'.$longestNick.']0}}$1');
    Irssi::command('^format pubmsg_channel {pubmsgnick $2 {pubnick '.$_[0].'$[-'.$longestNick.']0}}$1');
}

sub color_right($) {
    Irssi::command('^format pubmsg {pubmsgnick {pubnick '.$_[0].'$[-'.$longestNick.']0}$2}$1');
    Irssi::command('^format pubmsg_channel {pubmsgnick {pubnick '.$_[0].'$[-'.$longestNick.']0}$2}$1');
}

sub sig_public {
    my ($server, $msg, $nick, $address, $target) = @_;

    &$alignment($saved_colors{$nick});
}

sub sig_setup {
    @colors = split(//, Irssi::settings_get_str('neat_colors'));

    # check left or right alignment
    if (Irssi::settings_get_bool('neat_right_mode') == 0) {
        $alignment = \&color_left;
    } else {
        $alignment = \&color_right;
    }
  
    # check if we switched coloring on or off
    my $new = Irssi::settings_get_bool('neat_colorize');
    if ($new != $colorize) {
        if ($new) {
            Irssi::signal_add('message public', 'sig_public');
        } else {
            if ($colorize >= 0) {
                Irssi::signal_remove('message public', 'sig_public');
            }
        }
    }
    $colorize = $new;

    cmd_neatRedo();
    &$alignment('%w');
}

Irssi::settings_add_bool('misc', 'neat_right_mode', 1);
Irssi::settings_add_int('misc', 'neat_maxlength', 0);
Irssi::settings_add_bool('misc', 'neat_colorize', 1);
Irssi::settings_add_str('misc', 'neat_colors', 'rRgGyYbBmMcC');

Irssi::command_bind('neatredo', 'cmd_neatRedo');

Irssi::signal_add('nicklist new', 'sig_newNick');
Irssi::signal_add('nicklist changed', 'sig_changeNick');
Irssi::signal_add('nicklist remove', 'sig_removeNick');

Irssi::signal_add('setup changed', 'sig_setup');
Irssi::signal_add_last('setup reread', 'sig_setup');

sig_setup;
