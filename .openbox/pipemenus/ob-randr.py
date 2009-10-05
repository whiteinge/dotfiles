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

    outputs = {
        'current': [],
        'connected': [],
        'disconnected': []}

    for i in output:
        if ' current' in i:
            # ['800 x 480']
            mode = i.split(',')[1].replace('current ', '').strip()
            outputs['current'].append(mode)

        if ' connected' in i:
            # [['LVDS', '800x480+0+0', ['800x480', '640x480']]
            mode = i.replace(' connected', '').partition('(')[0].strip().split(' ')
            mode.append([])

            for j in output[output.index(i) + 1:]:
                if j.startswith(' '):
                    mode[-1].append(j.strip().split(' ')[0])
                else:
                    break

            outputs['connected'].append(mode)

        if ' disconnected' in i:
            # [['VGA', '1440x900+0+0'], ['TV']]
            mode = i.replace(' disconnected', '').partition('(')[0].strip().split(' ')
            outputs['disconnected'].append(mode)

    return outputs

def get_xml():
    """Build the XML tree that OpenBox is expecting."""
    outputs = get_output()

    root = etree.Element('openbox_pipe_menu')
    etree.SubElement(root, 'separator', label="Current: " + ', '.join(outputs['current']))

    # Add all the connected outputs as interactive menus
    for output in outputs['connected']:
        CMD = 'xrandr --output %s ' % output[0]
        OUT = etree.SubElement(root, 'menu',
                label='Connected: %s (%s)' % (output[0], output[1]),
                id=output[0].lower())

        modes = etree.SubElement(OUT, 'menu', label='Modes', id='modes')
        for i in output[2]:
            etree.SubElement(modes, 'item', label=i)

        etree.SubElement(OUT, 'separator')

        actions = (
            ('zoom_out', '--scale 1.3x1.3'),
            ('zoom in', '--panning 1280x1024'),
            (),
            ('left', '--rotate left'),
            ('right', '--rotate right'),
            ('invert', '--rotate invert'),
            (),
            ('on', '--off'),
            ('off', '--on'),
            (),
            ('reset', ' '.join([
                '--auto', '--rotate normal', '--scale 1x1', '--panning 0x0'])))

        for action in actions:
            if action:
                k,v = action
                item = etree.SubElement(OUT, 'item', label=k.replace('_', ' '))
                action = etree.SubElement(item, 'action', name='execute')
                etree.SubElement(action, 'command').text = CMD + v
            else:
                etree.SubElement(OUT, 'separator')

    # Add all the disconnected outputs as static list items
    etree.SubElement(root, 'separator')
    for output in outputs['disconnected']:
        etree.SubElement(root, 'item',
            label='Disconnected: %s (%s)' % (output[0], ' '.join(output[2:])))

    return etree.tostring(root)

if __name__ == '__main__':
    sys.stdout.write(get_xml() + '\n')
