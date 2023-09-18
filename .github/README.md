# dotfiles

These files cover my core stack of Vim, tmux, Zsh, ctags, fzy, Git, and ssh.
With those as a baseline, I can feel immediately at home and productive on most
any POSIX-like environment.

- The many [custom scripts in
  ~/bin](https://github.com/whiteinge/dotfiles/tree/master/bin#readme) augment
  that with additional and custom functionality.
- I often compile my own copies of several programs such as Vim, and the repos
  linked in
  [~/opt/repos](https://github.com/whiteinge/dotfiles/tree/master/opt/repos)
- Common packages, by OS, and other configuration are kept in
  [~/opt](https://github.com/whiteinge/dotfiles/tree/master/opt).

![](https://www.eseth.org/2019/tmux-status-line.png)

## Installation

The layout of this repo is intended to be used directly in a home folder. The
commands below will overwrite any existing files in your home directory.

```sh
git clone --bare https://github.com/whiteinge/dotfiles.git $HOME/src/dotfiles.git
git --git-dir=$HOME/src/dotfiles.git --work-tree=$HOME checkout -f master
git --git-dir=$HOME/src/dotfiles.git --work-tree=$HOME submodule update --init
```

The various `~/bin/boostrap-*` scripts can complete any other needed
configuration.

Once installed and running Zsh, [dotfiles
mode](https://github.com/whiteinge/dotfiles/blob/f1b8daa/.zshrc#L324-L347) can
be toggled on and off to run repo commands without the need for long flags.

## Me

On occassion I will [blog about these dotfiles](https://www.eseth.org/), or
give [presentations about Linux or programming
topics](https://github.com/whiteinge/presentations#readme).

I float between a number of environments for work, mobile, personal, and hobby
needs. My preferred terminal is xterm because it is reliable and works exactly
the same across platforms (XQuartz on OS X, WSL on Windows, and any Linux).
I prefer the minimal [CWM window
manager](https://github.com/leahneukirchen/cwm#readme), or Gnome when
necessary. My distro of choice is a minimal Fedora install, but sporting an "I
wish I was running Slackware" bumper-sticker.

## History

These dotfiles date back to maybe 2002 and started specifically for Zsh and Vim
customizations. I went from plain files, to uploading files to my website, to
RCS, to Subversion, then Mercurial, then finally Git.

I have used quite a few different distros and operating systems over the years
such as BeOS, Mac, many Linuxes, and Windows. I try to remove files that don't
see somewhat regular use so the repo history is the only place to find old and
unused configuration.

The installation proceedure went from copying files from box to box, to
a `movein.sh` script, to
a [dotsync](https://github.com/whiteinge/dotfiles/blob/6a2377c/.zshrc#L228)
shell function, to cloning a repo and running manual steps, to cloning a repo
and running one or more bootstrap scripts.

Prior to [e4ebf44](https://github.com/whiteinge/dotfiles/commit/e4ebf44) I used
`lndir` to symlink my dotfiles from `~/src/dotfiles` to `$HOME`; it is packaged
for most distros (usually in one of the X11 packages or XQuartz on OS X), but
I created a `~/bin/lndir.sh` script that also does the trick, just more slowly.
It is very simple and works great. The Git worktree approach is much less
simple and requires strong Git knowledge, but has some small advantages such as
being able to use Git statuses to identify and clean cruft out of the home dir,
and directly updating submodules.
