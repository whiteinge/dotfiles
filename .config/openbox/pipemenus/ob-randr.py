#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""A small utility to make xrandr adjustments from an OpenBox menu.

To install, put this file somewhere and make sure it is executable.

Edit your $HOME/.config/openbox/menu.xml file. Add something like the following
near the top::

    <menu id="randr-menu" label="randr" execute="/path/to/ob-randr.py" />

Then add this in the place you actually want the menu to appear::

    <menu id="randr-menu" />

You can easily add custom commands to the menu by creating the file
$HOME/.ob-randrrc. The syntax looks like this::

    [Notebook]

    portrait: --output LVDS --primary --mode 1366x768 --output VGA-0 --mode 1440x900 --left-of LVDS --rotate left

    [Netbook]

    zoom out: --output LVDS --scale 1.3x1.3
    zoom in: --output LVDS --panning 1280x1024

The idea is that you can create machine-specific shortcuts. For example, with
my laptop at home I frequently connect to an external widescreen display turned
sideways. On my netbook, I frequently 'zoom out' to a higher resolution in
scaled-out mode or 'zoom in' to a higher resolution in panning mode.


TODO:

* Add left-of, right-of, above, below, same-as menus for active displays.
* What other common tasks should be represented?

"""
AUTHOR = 'Seth House <seth@eseth.com>'
VERSION = '0.1'

import ConfigParser
import os
import subprocess
import sys

try:
    from xml.etree import cElementTree as etree
except ImportError:
    from xml.etree import ElementTree as etree

HOME = os.path.expanduser('~')
RCFILE = '.ob-randrrc'

def mk_exe_node(output, name, command):
    """A small helper to speed the three-element PITA that is the OpenBox
    execute menu syntax.

    """
    CMD = 'xrandr --output %s ' % output

    item = etree.Element('item', label=name)
    action = etree.SubElement(item, 'action', name='execute')
    etree.SubElement(action, 'command').text = CMD + command

    return item

def get_rc_menu():
    """Read the user's rc file and return XML for menu entries."""
    config = ConfigParser.ConfigParser()
    config.read(os.path.join(HOME, RCFILE))

    menus = []

    for i in config.sections():
        menu = etree.Element('menu', id='shortcut-%s' % i, label=i)

        for name in config.options(i):
            command = config.get(i, name)

            item = etree.SubElement(menu, 'item', label=name)
            action = etree.SubElement(item, 'action', name='execute')
            etree.SubElement(action, 'command').text = 'xrandr ' + command

        menus.append(menu)

    return menus

def get_xml():
    """Run xrandr -q and parse the output for the bits we're interested in,
    then build an XML tree suitable for passing to OpenBox.

    """
    xrandr = subprocess.Popen(['xrandr', '-q'], stdout=subprocess.PIPE)
    xrandr_lines = xrandr.stdout.readlines()

    root = etree.Element('openbox_pipe_menu')

    actions = (
        ('right', '--rotate right'),
        ('left', '--rotate left'),
        ('inverted', '--rotate inverted'),
        ('normal', '--rotate normal'),
        (),
        ('on', '--on'),
        ('off', '--off'),
        (),
        ('auto', '--auto'),
        ('reset', ' '.join([
            '--auto', '--rotate normal', '--scale 1x1', '--panning 0x0'])))

    # The following string processing is far more verbose than necessary but if
    # the xrandr output ever changes (or I simply got it wrong to begin with)
    # this should make it easier to fix.
    for i in xrandr_lines:
        if ' current' in i:
            # Screen 0: minimum 320 x 200, current 1700 x 1440, maximum 2048 x 2048
            text = [j for j in i.split(',') if ' current' in j][0]
            text = text.replace(' current ', '')

            etree.SubElement(root, 'separator', label="Current: %s" % text)

        elif ' connected' in i:
            # VGA connected 900x1440+0+0 left (normal left inverted right x axis y axis) 408mm x 255mm
            text = i.replace(' connected', '')
            text = text.partition('(')[0]
            text = text.strip()

            try:
                output, mode, extra = (lambda x: (x[0], x[1], x[2:]))(text.split(' '))
            except IndexError:
                # LVDS connected (normal left inverted right x axis y axis)
                # Display is connected but off. Is this the best place to check that?
                output, mode, extra = text, 'off', ''

            node = etree.SubElement(root, 'menu', id=output, type='output',
                    label=' '.join([output, mode, ' '.join(extra)]))
            modes = etree.SubElement(node, 'menu', id='%s-modes' % output,
                    type='modes', label='modes')
            etree.SubElement(node, 'separator')

            # Grab all the available modes (I'm ignoring refresh rates for now)
            for j in xrandr_lines[xrandr_lines.index(i) + 1:]:
                if not j.startswith(' '):
                    break

                #   1440x900       59.9*+   59.9*
                text = j.strip()
                text = text.split(' ')[0]

                modes.append(mk_exe_node(output, text, '--mode %s' % text))

            for action in actions:
                if not action:
                    etree.SubElement(node, 'separator')
                else:
                    node.append(mk_exe_node(output, *action))

        elif ' disconnected' in i:
            # TV disconnected (normal left inverted right x axis y axis)
            text = i.replace(' disconnected', '')
            text = text.partition('(')[0]
            name, extra = (lambda x: (x[0], x[1:]))(text.split(' '))

            etree.SubElement(root, 'item', label=name)

    # Grab the user's rc menu shortcuts
    etree.SubElement(root, 'separator', label='Shortcuts')

    auto = etree.SubElement(root, 'item', label='auto')
    auto_action = etree.SubElement(auto, 'action', name='execute')
    etree.SubElement(auto_action, 'command').text = 'xrandr --auto'

    for i in get_rc_menu():
        root.append(i)

    return root

if __name__ == '__main__':
    ob_menu = get_xml()
    sys.stdout.write(etree.tostring(ob_menu) + '\n')
