#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""A small utility to make xrandr adjustments from an OpenBox menu."""
AUTHOR = 'Seth House <seth@eseth.com>'
VERSION = '0.1'

import subprocess
import sys

try:
    from xml.etree import cElementTree as etree
except ImportError:
    from xml.etree import ElementTree as etree


def get_output():
    """Run xrandr -q and parse the output for the bits we're interested in."""
    xrandr = subprocess.Popen(['xrandr', '-q'], stdout=subprocess.PIPE)
    output = xrandr.stdout.readlines()

    current = [i.split(',')[1].strip('current ')
            for i in output if ' current' in i]
    outputs = [i.partition('(')[0].strip().split(' ')
            for i in output if 'connected' in i]

    return current, outputs


def get_xml():
    """Build the XML tree that OpenBox is expecting."""
    current, outputs = get_output()

    root = etree.Element('openbox_pipe_menu')
    etree.SubElement(root, 'separator', label="Current: " + ', '.join(current))

    # Add all the connected outputs as interactive menus
    for output in [i for i in outputs if 'connected' in i]:
        CMD = 'xrandr --output %s ' % output[0]

        OUT = etree.SubElement(root, 'menu',
                label='Connected: %s (%s)' % (output[0], ' '.join(output[2:])),
                id=output[0].lower())

        actions = (
            ('zoom_out', '--scale 1.3x1.3'),
            ('pan', '--panning 1280x1024'),
            ('left', '--rotate left'),
            ('right', '--rotate right'),
            ('invert', '--rotate invert'),
            ('on', '--off'),
            ('off', '--on'),
            ('reset', ' '.join([
                '--auto', '--rotate normal', '--scale 1x1', '--panning 0x0'])))

        for k,v in actions:
            item = etree.SubElement(OUT, 'item', label=k.replace('_', ' '))
            action = etree.SubElement(item, 'action', name='execute')
            etree.SubElement(action, 'command').text = CMD + v

    # Add all the disconnected outputs as static list items
    for output in [i for i in outputs if 'disconnected' in i]:
        etree.SubElement(root, 'item',
            label='Disconnected: %s (%s)' % (output[0], ' '.join(output[2:])))

    return etree.tostring(root)


if __name__ == '__main__':
    sys.stdout.write(get_xml() + '\n')
