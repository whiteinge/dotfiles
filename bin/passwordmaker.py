#!/usr/bin/env python
# coding: utf-8
"""
  PasswordMaker - Creates and manages passwords
  Copyright (C) 2005 Eric H. Jung and LeahScape, Inc.
  http://passwordmaker.org/
  grimholtz@yahoo.com

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation; either version 2.1 of the License, or (at
  your option) any later version.

  This library is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 
  Written by Miquel Burns and Eric H. Jung

  PHP version written by Pedro Gimeno Fortea
      <http://www.formauri.es/personal/pgimeno/>
  and updated by Miquel Matthew 'Fire' Burns
      <miquelfire@gmail.com>
  Ported to Python by Aurelien Bompard
      <http://aurelien.bompard.org> 
  Updated by Richard Beales
      <rich@richbeales.net>

  This version should work with python > 2.3. The pycrypto module enables
  additional algorithms.

  Can be used both on the command-line and with a GUI based on TKinter
"""
from pwmlib import *

def gui():
    import Tkinter
    class Application(Tkinter.Frame):
        def __init__(self, master=None):
            Tkinter.Frame.__init__(self, master)
            self.grid()
            self.settings = PWM_Settings()
            self.createWidgets()
        def createWidgets(self):
            settings = self.settings
            # Create the widgets
            self.url_label = Tkinter.Label(self, justify="left", text="URL")
            self.url_text = Tkinter.Entry(self)
            self.url_text.insert(0, settings.URL)
            self.mpw_label = Tkinter.Label(self, justify="left", text="Master")
            self.mpw_text = Tkinter.Entry(self, show="*")
            self.mpw_text.insert(0, "")
            self.alg_label = Tkinter.Label(self, justify="left", text="Algorithm")
            self.alg_text = Tkinter.Entry(self)
            self.alg_text.insert(0, settings.Algorithm)
            self.user_label = Tkinter.Label(self, justify="left", text="Username")
            self.user_text = Tkinter.Entry(self)
            self.user_text.insert(0, settings.Username)
            self.mod_label = Tkinter.Label(self, justify="left", text="Modifier")
            self.mod_text = Tkinter.Entry(self)
            self.mod_text.insert(0, settings.Modifier)
            self.len_label = Tkinter.Label(self, justify="left", text="Length")
            self.len_text = Tkinter.Entry(self)
            self.len_text.insert(0, str(settings.Length))
            self.charset_label = Tkinter.Label(self, justify="left", text="Characters")
            self.charset_text = Tkinter.Entry(self)
            self.charset_text.insert(0, settings.CharacterSet)
            self.pfx_label = Tkinter.Label(self, justify="left", text="Prefix")
            self.pfx_text = Tkinter.Entry(self)
            self.pfx_text.insert(0, settings.Prefix)
            self.sfx_label = Tkinter.Label(self, justify="left", text="Suffix")
            self.sfx_text = Tkinter.Entry(self)
            self.sfx_text.insert(0, settings.Suffix)
            self.generate_button = Tkinter.Button (self, text="Generate", command=self.generate)
            self.load_button = Tkinter.Button (self, text="Load", command=self.load)
            self.save_button = Tkinter.Button (self, text="Save", command=self.save)
            self.passwd_label = Tkinter.Label(self, justify="left", text="Password")
            self.passwd_text = Tkinter.Entry(self, fg="blue")
            # Place on the grid
            self.url_label.grid(row=0,column=0)
            self.url_text.grid(row=0,column=1)
            self.mpw_label.grid(row=1,column=0)
            self.mpw_text.grid(row=1,column=1)
            self.alg_label.grid(row=2,column=0)
            self.alg_text.grid(row=2,column=1)
            self.user_label.grid(row=3,column=0)
            self.user_text.grid(row=3,column=1)
            self.mod_label.grid(row=4,column=0)
            self.mod_text.grid(row=4,column=1)
            self.len_label.grid(row=5,column=0)
            self.len_text.grid(row=5,column=1)
            self.charset_label.grid(row=6,column=0)
            self.charset_text.grid(row=6,column=1)
            self.pfx_label.grid(row=7,column=0)
            self.pfx_text.grid(row=7,column=1)
            self.sfx_label.grid(row=8,column=0)
            self.sfx_text.grid(row=8,column=1)
            self.generate_button.grid(row=9,column=0,columnspan=2,pady=5)
            self.load_button.grid(row=10,column=0,columnspan=1,pady=5)
            self.save_button.grid(row=10,column=1,columnspan=1,pady=5)
            self.passwd_label.grid(row=11,column=0)
            self.passwd_text.grid(row=11,column=1,sticky="nsew")

        def save(self):
            self.settings.URL = self.url_text.get()
            self.settings.Algorithm = self.alg_text.get() 
            self.settings.Username = self.user_text.get()
            self.settings.Modifier = self.mod_text.get()
            self.settings.Length = self.len_text.get()
            self.settings.CharacterSet = self.charset_text.get()
            self.settings.Prefix = self.pfx_text.get()
            self.settings.Suffix = self.sfx_text.get()
            self.settings.save()

        def load(self):
            self.settings = self.settings.load()
            self.createWidgets()

        def generate(self):
            self.generate_button.flash()
            try:
                PWmaker = PWM()
                pw = PWmaker.generatepassword(self.alg_text.get(),
                                      self.mpw_text.get(),
                                      self.url_text.get() + self.user_text.get() + self.mod_text.get(),
                                      self.settings.UseLeet,
                                      self.settings.LeetLvl - 1,
                                      int(self.len_text.get()),
                                      self.charset_text.get(),
                                      self.pfx_text.get(),
                                      self.sfx_text.get(),
                                     )
            except PWM_Error, e:
                pw = str(e)
            current_passwd = self.passwd_text.get()
            if len(current_passwd) > 0:
                self.passwd_text.delete(0,len(current_passwd))
            self.passwd_text.insert(0,pw)
    app = Application()
    app.master.title("PasswordMaker")
    app.mainloop()


def cmd():
    usage = "Usage: %prog [options]"
    settings = PWM_Settings()
    settings.load()
    parser = optparse.OptionParser(usage=usage)
    parser.add_option("-a", "--alg", dest="alg", default=settings.Algorithm, help="Hash algorithm [hmac-] md4/md5/sha1/sha256/rmd160 [_v6] (default " + settings.Algorithm + ")")
    parser.add_option("-m", "--mpw", dest="mpw", help="Master password (default: ask)", default="")
    parser.add_option("-r", "--url", dest="url", help="URL (default blank)", default=settings.URL)
    parser.add_option("-u", "--user", dest="user", help="Username (default blank)", default=settings.Username)
    parser.add_option("-d", "--modifier", dest="mod", help="Password modifier (default blank)", default=settings.Modifier)
    parser.add_option("-g", "--length", dest="len", help="Password length (default 8)", default=settings.Length, type="int")
    parser.add_option("-c", "--charset", dest="charset", help="Characters to use in password (default [A-Za-z0-9])", default=settings.CharacterSet)
    parser.add_option("-p", "--prefix", dest="pfx", help="Password prefix (default blank)", default=settings.Prefix)
    parser.add_option("-s", "--suffix", dest="sfx", help="Password suffix (default blank)", default=settings.Suffix)
    (options, args) = parser.parse_args()
    if options.mpw == "":
        import getpass
        options.mpw = getpass.getpass("Master password: ")
    # we don't support leet yet
    leet = None
    leetlevel = 0
    try:
        PWmaker = PWM()
        print PWmaker.generatepassword(options.alg,
                               options.mpw,
                               options.url + options.user + options.mod,
                               leet,
                               leetlevel - 1,
                               options.len,
                               options.charset,
                               options.pfx,
                               options.sfx,
                              )
    except PWM_Error, e:
        print e
        sys.exit(1)


# Main
if __name__ == "__main__":
    if len(sys.argv) == 1:
        gui()
    else:
        cmd()



