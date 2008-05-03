
use strict;

use Irssi ();
use vars qw($VERSION %IRSSI);

use POSIX ();
use constant OPEN_MAX => POSIX::sysconf(POSIX::_SC_OPEN_MAX());


$VERSION = '0.4';
%IRSSI = (
    authors	=> 'Schnell, Arvin',
    contact	=> 'aschnell@suse.de',
    name	=> 'hilight_notify',
    description	=> 'runs xmessage when a window gets hilighted',
    license	=> 'GPL',
    url		=> 'http://arvin.schnell-web.net/irssi/',
    changed	=> 'Tue Feb 12 18:57:03 CET 2008'
);


# 'Hilight Notify'. Runs xmessage or some other command when a window gets
# hilighted.
#
# /set hilight_notify <ON|OFF>
#       * ON|OFF : turn notification on or off
#
# /set hilight_notify_delay <int>
#       * int    : delay in seconds before notification appears
#
# /set hilight_notify_command <string>
#       * string : command to run on notification
#
# /set hilight_notify_display <string>
#       * string : value for 'DISPLAY' environment variable
#
# /hilight-notify-test
#	starts the notify command, useful for testing


my $status = 0;
my $timer = undef;
my $pid = undef;


sub start_proc()
{
    undef $timer;

    return if defined $pid;

    my $command = Irssi::settings_get_str('hilight_notify_command');
    my $display = Irssi::settings_get_str('hilight_notify_display');

    if ($pid = fork())
    {
	Irssi::pidwait_add($pid);
    }
    elsif (defined $pid)
    {
	foreach (3..OPEN_MAX) {
	    POSIX::close($_);
	}
	$ENV{'DISPLAY'} = $display if $display ne '';
	exec($command);
	die;
    }
}


sub check_proc($)
{
    return if !defined $pid;

    if ($_[0] == $pid) {
	undef $pid;
    }
}


sub check_windows()
{
    my $old_status = $status;

    $status = 0;
    foreach my $win (Irssi::windows())
    {
	if ($win->{data_level} == 3) {
	    $status = 1;
	}
    }

    if ($status == 1 && $old_status == 0)
    {
	if (!defined $timer && Irssi::settings_get_bool('hilight_notify') == 1)
	{
	    my $timeout = Irssi::settings_get_int('hilight_notify_delay');
	    $timer = Irssi::timeout_add_once($timeout*1000, 'start_proc', undef);
	}
    }

    if ($status == 0 && $old_status == 1)
    {
	if (defined $timer) {
	    Irssi::timeout_remove($timer);
	    undef $timer;
	}

	if (defined $pid)
	{
	    kill(15, $pid);
	}
    }
}


Irssi::settings_add_bool('hilight_notify', 'hilight_notify', 1);
Irssi::settings_add_int('hilight_notify', 'hilight_notify_delay', 10);
Irssi::settings_add_str('hilight_notify', 'hilight_notify_command',
			'xmessage -center "IRC needs your attention"');
Irssi::settings_add_str('hilight_notify', 'hilight_notify_display', '');

Irssi::signal_add_last('window hilight', 'check_windows');
Irssi::signal_add_last('pidwait', 'check_proc');

Irssi::command_bind('hilight-notify-test', 'start_proc');

